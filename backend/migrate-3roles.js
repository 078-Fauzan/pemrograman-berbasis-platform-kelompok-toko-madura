const { pool } = require('./src/config/database');

async function migrate() {
  try {
    console.log('--- Memulai Migrasi Database 3-Role & Orders ---');

    // 1. Modifikasi ENUM role di tabel users & tambah kolom address
    console.log('1. Memperbarui kolom role & address di tabel users...');
    await pool.query(
      "ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'owner', 'cashier', 'customer') NOT NULL DEFAULT 'customer'"
    );

    await pool.query(
      "ALTER TABLE notifications MODIFY COLUMN type ENUM('stock_alert', 'system', 'transaction', 'order', 'order_status') NOT NULL DEFAULT 'system'"
    );

    const [cols] = await pool.query("SHOW COLUMNS FROM users LIKE 'address'");
    if (cols.length === 0) {
      await pool.query("ALTER TABLE users ADD COLUMN address TEXT NULL AFTER phone");
      console.log('   -> Kolom address berhasil ditambahkan ke users.');
    } else {
      console.log('   -> Kolom address sudah ada.');
    }

    // 2. Buat tabel orders
    console.log('2. Membuat tabel orders...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        store_id INT NOT NULL DEFAULT 1,
        user_id INT NOT NULL,
        order_number VARCHAR(50) NOT NULL UNIQUE,
        customer_name VARCHAR(150) NOT NULL,
        customer_phone VARCHAR(25) NOT NULL,
        total_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
        order_type ENUM('takeaway', 'delivery') NOT NULL DEFAULT 'takeaway',
        delivery_address TEXT NULL,
        payment_method ENUM('cash', 'qris', 'transfer') NOT NULL DEFAULT 'cash',
        status ENUM('pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
        notes TEXT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_orders_store FOREIGN KEY (store_id) REFERENCES stores (id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        INDEX idx_orders_store_status (store_id, status),
        INDEX idx_orders_user (user_id),
        INDEX idx_orders_created (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('   -> Tabel orders siap.');

    // 3. Buat tabel order_items
    console.log('3. Membuat tabel order_items...');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        product_id INT NOT NULL,
        product_name VARCHAR(200) NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        price DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
        subtotal DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
        CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE ON UPDATE CASCADE,
        CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT ON UPDATE CASCADE,
        INDEX idx_order_items_order (order_id),
        INDEX idx_order_items_product (product_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    `);
    console.log('   -> Tabel order_items siap.');

    // 4. Data demo akun customer
    console.log('4. Memeriksa akun demo customer...');
    const [custRows] = await pool.query("SELECT id FROM users WHERE email = 'customer@umkmate.com'");
    if (custRows.length === 0) {
      await pool.query(
        `INSERT INTO users (store_id, name, email, password, phone, address, role, is_active, created_at, updated_at)
         VALUES (1, 'Budi Pembeli', 'customer@umkmate.com', '$2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe', '085211223344', 'Jl. Kaliurang KM 5 Gang Pandega Marta No. 8, Sleman', 'customer', 1, NOW(), NOW())`
      );
      console.log('   -> Akun demo customer dibuat: customer@umkmate.com (Password: Password123!)');
    } else {
      console.log('   -> Akun demo customer sudah ada.');
    }

    // 5. Data demo akun admin
    console.log('5. Memeriksa akun demo admin...');
    const [adminRows] = await pool.query("SELECT id FROM users WHERE email = 'admin@umkmate.com'");
    if (adminRows.length === 0) {
      await pool.query(
        `INSERT INTO users (store_id, name, email, password, phone, address, role, is_active, created_at, updated_at)
         VALUES (1, 'Admin Toko Madura', 'admin@umkmate.com', '$2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe', '081234567899', 'Jl. Kaliurang KM 5.5 No. 12, Sleman', 'admin', 1, NOW(), NOW())`
      );
      console.log('   -> Akun demo admin dibuat: admin@umkmate.com (Password: Password123!)');
    } else {
      console.log('   -> Akun demo admin sudah ada.');
    }

    // 6. Buat sampel order untuk pengujian awal
    const [ordersCount] = await pool.query('SELECT COUNT(*) as count FROM orders');
    if (ordersCount[0].count === 0) {
      const [user] = await pool.query("SELECT id FROM users WHERE email = 'customer@umkmate.com'");
      const customerUserId = user[0].id;

      const [orderRes] = await pool.query(
        `INSERT INTO orders (store_id, user_id, order_number, customer_name, customer_phone, total_amount, order_type, delivery_address, payment_method, status, notes, created_at, updated_at)
         VALUES (1, ?, 'ORD-20261107-0001', 'Budi Pembeli', '085211223344', 36500.00, 'takeaway', 'Jl. Kaliurang KM 5', 'cash', 'pending', 'Tolong siapkan, nanti sore diambil jam 17:00', NOW(), NOW())`,
        [customerUserId]
      );
      const orderId = orderRes.insertId;

      await pool.query(
        `INSERT INTO order_items (order_id, product_id, product_name, quantity, price, subtotal)
         VALUES (?, 15, 'Indomie Goreng Original 85 gr', 3, 3500.00, 10500.00),
                (?, 27, 'Sampoerna A Mild 16 Batang', 1, 26000.00, 26000.00)`,
        [orderId, orderId]
      );
      console.log('   -> Sampel pesanan demo ORD-20261107-0001 berhasil dibuat.');
    }

    console.log('\n✅ MIGRASI DATABASE BERHASIL 100%!');
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error('❌ Gagal migrasi database:', err);
    process.exit(1);
  }
}

migrate();
