const { pool } = require('../config/database');
const { hashPassword } = require('../utils/passwordHelper');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/users (Mengambil daftar staf/kasir toko)
 */
async function getUsers(req, res, next) {
  try {
    const storeId = req.user.storeId;

    const [users] = await pool.query(
      `SELECT id, store_id, name, email, phone, role, is_active, created_at, updated_at
       FROM users
       WHERE store_id = ?
       ORDER BY (role = 'owner') DESC, id ASC`,
      [storeId]
    );

    return successResponse(res, users, 'Daftar pengguna toko berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/users (Owner membuat akun kasir baru)
 */
async function createUser(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { name, email, password, phone = null } = req.body;

    // Periksa apakah email sudah terdaftar
    const [existing] = await pool.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return errorResponse(res, 'Email sudah terdaftar sebagai pengguna sistem.', 409);
    }

    const hashedPassword = await hashPassword(password);

    const [result] = await pool.query(
      `INSERT INTO users (store_id, name, email, password, phone, role, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 'cashier', 1, NOW(), NOW())`,
      [storeId, name, email, hashedPassword, phone]
    );

    const newUserId = result.insertId;

    // Catat log aktivitas
    await pool.query(
      `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
       VALUES (?, ?, 'CREATE_CASHIER', ?, NOW())`,
      [storeId, req.user.userId, `Owner menambahkan kasir baru: ${name} (${email})`]
    );

    return successResponse(
      res,
      {
        id: newUserId,
        store_id: storeId,
        name,
        email,
        phone,
        role: 'cashier',
        is_active: 1,
      },
      'Akun kasir berhasil dibuat.',
      201
    );
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/users/:id (Mengambil detail satu kasir)
 */
async function getUserById(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [rows] = await pool.query(
      `SELECT id, store_id, name, email, phone, role, is_active, created_at, updated_at
       FROM users
       WHERE id = ? AND store_id = ?`,
      [id, storeId]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Pengguna tidak ditemukan pada toko ini.', 404);
    }

    return successResponse(res, rows[0], 'Detail pengguna berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/users/:id (Memperbarui data akun kasir)
 */
async function updateUser(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { name, phone, password } = req.body;

    // Pastikan user ada dan merupakan milik toko yang sama
    const [rows] = await pool.query(
      'SELECT id, role FROM users WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Pengguna tidak ditemukan pada toko ini.', 404);
    }

    const updates = [];
    const params = [];

    if (name) {
      updates.push('name = ?');
      params.push(name);
    }

    if (phone !== undefined) {
      updates.push('phone = ?');
      params.push(phone);
    }

    if (password) {
      const hashedPassword = await hashPassword(password);
      updates.push('password = ?');
      params.push(hashedPassword);
    }

    if (updates.length > 0) {
      updates.push('updated_at = NOW()');
      params.push(id, storeId);

      await pool.query(
        `UPDATE users SET ${updates.join(', ')} WHERE id = ? AND store_id = ?`,
        params
      );
    }

    const [updatedRows] = await pool.query(
      'SELECT id, store_id, name, email, phone, role, is_active, updated_at FROM users WHERE id = ?',
      [id]
    );

    return successResponse(res, updatedRows[0], 'Data pengguna berhasil diperbarui.');
  } catch (error) {
    next(error);
  }
}

/**
 * PATCH /api/v1/users/:id/status (Mengaktifkan atau menonaktifkan akun kasir)
 */
async function updateUserStatus(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { is_active } = req.body;

    // Pastikan target bukan akun owner itu sendiri
    const [rows] = await pool.query(
      'SELECT id, role, name, email FROM users WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Pengguna tidak ditemukan pada toko ini.', 404);
    }

    const targetUser = rows[0];

    if (targetUser.role === 'owner' || targetUser.role === 'admin') {
      return errorResponse(res, 'Akun administrator/pemilik toko tidak dapat dinonaktifkan.', 400);
    }

    const statusValue = is_active ? 1 : 0;

    await pool.query(
      'UPDATE users SET is_active = ?, updated_at = NOW() WHERE id = ? AND store_id = ?',
      [statusValue, id, storeId]
    );

    // Catat ke activity logs
    await pool.query(
      `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
       VALUES (?, ?, 'UPDATE_CASHIER_STATUS', ?, NOW())`,
      [
        storeId,
        req.user.userId,
        `Owner mengubah status kasir ${targetUser.name} menjadi ${statusValue ? 'AKTIF' : 'NONAKTIF'}`,
      ]
    );

    return successResponse(
      res,
      {
        id: targetUser.id,
        name: targetUser.name,
        is_active: statusValue,
      },
      `Status akun kasir berhasil diubah menjadi ${statusValue ? 'Aktif' : 'Nonaktif'}.`
    );
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getUsers,
  createUser,
  getUserById,
  updateUser,
  updateUserStatus,
};
