const { pool } = require('../config/database');
const { hashPassword, comparePassword } = require('../utils/passwordHelper');
const { generateToken, verifyToken } = require('../utils/tokenHelper');

/**
 * Registrasi Toko Baru & Akun Owner dalam 1 Database Transaction (ACID)
 */
async function registerStoreAndOwner({ store_name, owner_name, email, phone, password, address = null }) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. Periksa apakah email sudah terdaftar di users atau stores
    const [existingUsers] = await connection.query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );
    if (existingUsers.length > 0) {
      const err = new Error('Email sudah terdaftar sebagai pengguna.');
      err.statusCode = 409;
      throw err;
    }

    const [existingStores] = await connection.query(
      'SELECT id FROM stores WHERE email = ?',
      [email]
    );
    if (existingStores.length > 0) {
      const err = new Error('Email toko sudah terdaftar dalam sistem.');
      err.statusCode = 409;
      throw err;
    }

    // 2. Buat entitas toko baru
    const [storeResult] = await connection.query(
      `INSERT INTO stores (store_name, owner_name, email, phone, address, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
      [store_name, owner_name, email, phone, address]
    );
    const storeId = storeResult.insertId;

    // 3. Hash password owner
    const hashedPassword = await hashPassword(password);

    // 4. Buat akun owner toko
    const [userResult] = await connection.query(
      `INSERT INTO users (store_id, name, email, password, phone, role, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 'owner', 1, NOW(), NOW())`,
      [storeId, owner_name, email, hashedPassword, phone]
    );
    const userId = userResult.insertId;

    // 5. Buat kategori produk bawaan toko baru
    const defaultCategories = [
      'Sembako',
      'Minuman',
      'Makanan Ringan',
      'Sabun & Kebersihan',
      'Lain-lain',
    ];
    for (const catName of defaultCategories) {
      await connection.query(
        'INSERT INTO categories (store_id, category_name, created_at) VALUES (?, ?, NOW())',
        [storeId, catName]
      );
    }

    // 6. Buat kategori pengeluaran bawaan
    const defaultExpenseCategories = [
      'Listrik & Air',
      'Sewa Tempat',
      'Operasional Toko',
      'Transportasi Belanja Grosir',
    ];
    for (const expName of defaultExpenseCategories) {
      await connection.query(
        'INSERT INTO expense_categories (store_id, category_name, created_at) VALUES (?, ?, NOW())',
        [storeId, expName]
      );
    }

    // 7. Buat notifikasi sambutan
    await connection.query(
      `INSERT INTO notifications (store_id, user_id, title, message, type, is_read, created_at)
       VALUES (?, ?, 'Selamat Datang di UMKMate!', 'Toko Anda berhasil didaftarkan. Mulai tambahkan produk dan layani transaksi kasir.', 'system', 0, NOW())`,
      [storeId, userId]
    );

    // 8. Catat aktivitas audit
    await connection.query(
      `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
       VALUES (?, ?, 'REGISTER_STORE', 'Pendaftaran toko baru dan akun pemilik', NOW())`,
      [storeId, userId]
    );

    await connection.commit();

    // 9. Generate token JWT
    const token = generateToken({
      userId,
      storeId,
      role: 'owner',
      email,
    });

    return {
      token,
      user: {
        id: userId,
        store_id: storeId,
        name: owner_name,
        email,
        phone,
        role: 'owner',
        is_active: 1,
      },
      store: {
        id: storeId,
        store_name,
        owner_name,
        email,
        phone,
        address,
      },
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * Registrasi Pengunjung / Pembeli Baru (Customer)
 */
async function registerCustomer({ name, email, phone, password, address = null, store_id = 1 }) {
  // 1. Periksa email unik di users
  const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
  if (existing.length > 0) {
    const err = new Error('Email sudah terdaftar. Silakan login atau gunakan email lain.');
    err.statusCode = 409;
    throw err;
  }

  // 2. Hash password
  const hashedPassword = await hashPassword(password);

  // 3. Simpan pembeli
  const [result] = await pool.query(
    `INSERT INTO users (store_id, name, email, password, phone, address, role, is_active, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, 'customer', 1, NOW(), NOW())`,
    [store_id, name, email, hashedPassword, phone, address]
  );
  const userId = result.insertId;

  // 4. Ambil info toko
  const [stores] = await pool.query('SELECT id, store_name, phone, address FROM stores WHERE id = ?', [store_id]);
  const store = stores[0] || { id: store_id, store_name: 'Warung Madura', phone: '', address: '' };

  // 5. Generate token JWT
  const token = generateToken({
    userId,
    storeId: store_id,
    role: 'customer',
    email,
  });

  return {
    token,
    user: {
      id: userId,
      store_id,
      name,
      email,
      phone,
      address,
      role: 'customer',
      is_active: 1,
    },
    store: {
      id: store.id,
      store_name: store.store_name,
      phone: store.phone,
      address: store.address,
    },
  };
}

/**
 * Otentikasi Login Pengguna (Owner atau Kasir)
 */
async function loginUser({ email, password }) {
  // Ambil user dan nama tokonya
  const [rows] = await pool.query(
    `SELECT u.id, u.store_id, u.name, u.email, u.password, u.phone, u.address, u.role, u.is_active,
            s.store_name, s.address as store_address, s.phone as store_phone
     FROM users u
     JOIN stores s ON u.store_id = s.id
     WHERE u.email = ?`,
    [email]
  );

  if (rows.length === 0) {
    const err = new Error('Email atau kata sandi tidak sesuai.');
    err.statusCode = 401;
    throw err;
  }

  const user = rows[0];

  if (!user.is_active) {
    const err = new Error('Akun Anda telah dinonaktifkan oleh pemilik toko.');
    err.statusCode = 403;
    throw err;
  }

  const isPasswordMatch = await comparePassword(password, user.password);
  if (!isPasswordMatch) {
    const err = new Error('Email atau kata sandi tidak sesuai.');
    err.statusCode = 401;
    throw err;
  }

  // Catat login ke activity_logs
  await pool.query(
    `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
     VALUES (?, ?, 'LOGIN', 'Pengguna berhasil masuk ke dalam sistem', NOW())`,
    [user.store_id, user.id]
  );

  const token = generateToken({
    userId: user.id,
    storeId: user.store_id,
    role: user.role,
    email: user.email,
  });

  return {
    token,
    user: {
      id: user.id,
      store_id: user.store_id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.address,
      role: user.role,
      is_active: user.is_active,
    },
    store: {
      id: user.store_id,
      store_name: user.store_name,
      phone: user.store_phone,
      address: user.store_address,
    },
  };
}

/**
 * Mengambil profil akun pengguna yang sedang login
 */
async function getMe(userId, storeId) {
  const [rows] = await pool.query(
    `SELECT u.id, u.store_id, u.name, u.email, u.phone, u.address, u.role, u.is_active, u.created_at,
            s.store_name, s.owner_name, s.email as store_email, s.phone as store_phone, s.address as store_address
     FROM users u
     JOIN stores s ON u.store_id = s.id
     WHERE u.id = ? AND u.store_id = ?`,
    [userId, storeId]
  );

  if (rows.length === 0) {
    const err = new Error('Pengguna tidak ditemukan.');
    err.statusCode = 404;
    throw err;
  }

  const user = rows[0];
  return {
    user: {
      id: user.id,
      store_id: user.store_id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      address: user.address,
      role: user.role,
      is_active: user.is_active,
      created_at: user.created_at,
    },
    store: {
      id: user.store_id,
      store_name: user.store_name,
      owner_name: user.owner_name,
      email: user.store_email,
      phone: user.store_phone,
      address: user.store_address,
    },
  };
}

/**
 * Memperbarui profil pengguna & profil toko (khusus owner)
 */
async function updateProfile(userId, storeId, role, { name, phone, store_name, address }) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // 1. Update data personal pengguna (termasuk alamat pengguna)
    if (name || phone || address) {
      await connection.query(
        `UPDATE users 
         SET name = COALESCE(?, name),
             phone = COALESCE(?, phone),
             address = COALESCE(?, address),
             updated_at = NOW()
         WHERE id = ? AND store_id = ?`,
        [name || null, phone || null, address || null, userId, storeId]
      );
    }

    // 2. Jika role adalah owner / admin, perbarui data toko jika disertakan
    if ((role === 'owner' || role === 'admin') && (store_name || address)) {
      await connection.query(
        `UPDATE stores
         SET store_name = COALESCE(?, store_name),
             address = COALESCE(?, address),
             updated_at = NOW()
         WHERE id = ?`,
        [store_name || null, address || null, storeId]
      );
    }

    await connection.commit();
    return getMe(userId, storeId);
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

/**
 * Permintaan Reset Password (menghasilkan token reset sementara)
 */
async function requestForgotPassword(email) {
  const [rows] = await pool.query(
    'SELECT id, store_id, email, name FROM users WHERE email = ? AND is_active = 1',
    [email]
  );

  if (rows.length === 0) {
    // Demi alasan keamanan, jangan beritahu bahwa email tidak ditemukan
    return {
      message: 'Jika email terdaftar, instruksi reset password telah diproses.',
    };
  }

  const user = rows[0];
  // Buat token reset berlaku 1 jam
  const resetToken = generateToken(
    { userId: user.id, storeId: user.store_id, role: 'reset_pwd', email: user.email },
    '1h'
  );

  return {
    message: 'Token reset password berhasil dibuat.',
    reset_token: resetToken, // Dikembalikan untuk pengujian / integrasi mobile
  };
}

/**
 * Eksekusi Reset Password menggunakan token reset valid
 */
async function executeResetPassword(token, newPassword) {
  const decoded = verifyToken(token);
  if (!decoded || decoded.role !== 'reset_pwd') {
    const err = new Error('Token reset password tidak valid atau telah kedaluwarsa.');
    err.statusCode = 400;
    throw err;
  }

  const hashedPassword = await hashPassword(newPassword);

  const [result] = await pool.query(
    'UPDATE users SET password = ?, updated_at = NOW() WHERE id = ? AND email = ?',
    [hashedPassword, decoded.userId, decoded.email]
  );

  if (result.affectedRows === 0) {
    const err = new Error('Gagal mereset password. Pengguna tidak ditemukan.');
    err.statusCode = 404;
    throw err;
  }

  return {
    message: 'Kata sandi berhasil diperbarui. Silakan login kembali dengan kata sandi baru Anda.',
  };
}

module.exports = {
  registerStoreAndOwner,
  registerCustomer,
  loginUser,
  getMe,
  updateProfile,
  requestForgotPassword,
  executeResetPassword,
};
