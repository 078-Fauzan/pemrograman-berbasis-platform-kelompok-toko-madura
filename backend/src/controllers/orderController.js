const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * Helper untuk format nomor order: ORD-YYYYMMDD-XXXX
 */
function generateOrderNumber() {
  const now = new Date();
  const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '');
  const randomStr = Math.floor(1000 + Math.random() * 9000).toString();
  return `ORD-${dateStr}-${randomStr}`;
}

/**
 * GET /api/v1/orders
 * Mengambil daftar pesanan:
 * - Customer: hanya melihat riwayat pesanan miliknya sendiri
 * - Admin/Owner/Kasir: melihat seluruh pesanan toko (dengan filter status opsional)
 */
async function getOrders(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const userId = req.user.userId;
    const role = req.user.role;
    const isCustomer = role === 'customer';
    const { status, order_type } = req.query;

    let query = `
      SELECT o.id, o.store_id, o.user_id, o.order_number, o.customer_name, o.customer_phone,
             o.total_amount, o.order_type, o.delivery_address, o.payment_method,
             o.status, o.notes, o.created_at, o.updated_at,
             COUNT(oi.id) as total_items,
             SUM(oi.quantity) as total_qty
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.store_id = ?
    `;
    const params = [storeId];

    if (isCustomer) {
      query += ' AND o.user_id = ?';
      params.push(userId);
    }

    if (status) {
      query += ' AND o.status = ?';
      params.push(status);
    }

    if (order_type) {
      query += ' AND o.order_type = ?';
      params.push(order_type);
    }

    query += ' GROUP BY o.id ORDER BY o.created_at DESC';

    const [orders] = await pool.query(query, params);
    return successResponse(res, orders, 'Daftar pesanan berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/orders/:id
 * Mengambil detail 1 pesanan beserta rincian item (order_items)
 */
async function getOrderById(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const userId = req.user.userId;
    const isCustomer = req.user.role === 'customer';
    const { id } = req.params;

    let query = `
      SELECT o.id, o.store_id, o.user_id, o.order_number, o.customer_name, o.customer_phone,
             o.total_amount, o.order_type, o.delivery_address, o.payment_method,
             o.status, o.notes, o.created_at, o.updated_at
      FROM orders o
      WHERE o.id = ? AND o.store_id = ?
    `;
    const params = [id, storeId];

    if (isCustomer) {
      query += ' AND o.user_id = ?';
      params.push(userId);
    }

    const [orders] = await pool.query(query, params);
    if (orders.length === 0) {
      return errorResponse(res, 'Pesanan tidak ditemukan atau Anda tidak memiliki akses.', 404);
    }

    const order = orders[0];

    // Ambil item pesanan
    const [items] = await pool.query(
      `SELECT oi.id, oi.product_id, oi.product_name, oi.quantity, oi.price, oi.subtotal,
              p.barcode, p.unit
       FROM order_items oi
       LEFT JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = ?`,
      [order.id]
    );

    order.items = items;
    return successResponse(res, order, 'Detail pesanan berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/orders
 * Membuat pesanan baru oleh Pengunjung / Pembeli (atau Kasir/Admin)
 */
async function createOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const storeId = req.user.storeId;
    const userId = req.user.userId;
    const {
      order_type = 'takeaway',
      delivery_address = null,
      payment_method = 'cash',
      notes = null,
      items = [],
    } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      return errorResponse(res, 'Pesanan harus berisi minimal 1 produk.', 400);
    }

    // Ambil identitas pengguna
    const [users] = await connection.query(
      'SELECT name, phone, address FROM users WHERE id = ?',
      [userId]
    );
    if (users.length === 0) {
      return errorResponse(res, 'Pengguna tidak ditemukan.', 404);
    }
    const customerName = users[0].name;
    const customerPhone = users[0].phone || '-';
    const finalAddress = delivery_address || users[0].address || '-';

    // Verifikasi produk dan kalkulasi total secara aman di sisi server
    let totalAmount = 0;
    const verifiedItems = [];

    for (const item of items) {
      const qty = parseInt(item.quantity, 10);
      if (isNaN(qty) || qty <= 0) {
        await connection.rollback();
        return errorResponse(res, 'Jumlah barang tidak valid.', 400);
      }

      const [products] = await connection.query(
        'SELECT id, product_name, selling_price, stock, is_active FROM products WHERE id = ? AND store_id = ?',
        [item.product_id, storeId]
      );

      if (products.length === 0 || !products[0].is_active) {
        await connection.rollback();
        return errorResponse(res, `Produk dengan ID ${item.product_id} tidak tersedia.`, 400);
      }

      const prod = products[0];
      const price = parseFloat(prod.selling_price);
      const subtotal = price * qty;
      totalAmount += subtotal;

      verifiedItems.push({
        product_id: prod.id,
        product_name: prod.product_name,
        quantity: qty,
        price,
        subtotal,
      });
    }

    const orderNumber = generateOrderNumber();

    // Buat data order
    const [orderRes] = await connection.query(
      `INSERT INTO orders (store_id, user_id, order_number, customer_name, customer_phone,
                           total_amount, order_type, delivery_address, payment_method, status, notes, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, NOW(), NOW())`,
      [
        storeId,
        userId,
        orderNumber,
        customerName,
        customerPhone,
        totalAmount,
        order_type,
        finalAddress,
        payment_method,
        notes,
      ]
    );
    const orderId = orderRes.insertId;

    // Masukkan item order
    for (const item of verifiedItems) {
      await connection.query(
        `INSERT INTO order_items (order_id, product_id, product_name, quantity, price, subtotal)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [orderId, item.product_id, item.product_name, item.quantity, item.price, item.subtotal]
      );
    }

    // Catat notifikasi untuk pemilik/kasir
    await connection.query(
      `INSERT INTO notifications (store_id, user_id, title, message, type, is_read, created_at)
       VALUES (?, NULL, 'Pesanan Baru Masuk!', ?, 'order', 0, NOW())`,
      [storeId, `Pesanan ${orderNumber} senilai Rp ${totalAmount.toLocaleString('id-ID')} dari ${customerName}.`]
    );

    await connection.commit();

    return successResponse(
      res,
      {
        id: orderId,
        order_number: orderNumber,
        total_amount: totalAmount,
        status: 'pending',
        customer_name: customerName,
        items_count: verifiedItems.length,
      },
      'Pesanan berhasil dibuat.',
      201
    );
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

/**
 * PATCH /api/v1/orders/:id/status
 * Memperbarui status pesanan (khusus Admin, Owner, Kasir)
 * status: 'confirmed' | 'processing' | 'ready' | 'completed' | 'cancelled'
 */
async function updateOrderStatus(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return errorResponse(
        res,
        `Status tidak valid. Pilihan: ${validStatuses.join(', ')}`,
        400
      );
    }

    const [orders] = await pool.query(
      'SELECT id, order_number, user_id, status FROM orders WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (orders.length === 0) {
      return errorResponse(res, 'Pesanan tidak ditemukan.', 404);
    }

    await pool.query(
      'UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ? AND store_id = ?',
      [status, id, storeId]
    );

    // Kirim notifikasi ke pembeli
    const order = orders[0];
    const statusMsg = {
      confirmed: 'telah dikonfirmasi oleh warung.',
      processing: 'sedang disiapkan oleh kasir/penjual.',
      ready: 'sudah siap diambil di warung / siap diantar.',
      completed: 'telah selesai. Terima kasih telah berbelanja!',
      cancelled: 'dibatalkan.',
    }[status] || `diperbarui menjadi ${status}.`;

    await pool.query(
      `INSERT INTO notifications (store_id, user_id, title, message, type, is_read, created_at)
       VALUES (?, ?, 'Update Pesanan Anda', ?, 'order_status', 0, NOW())`,
      [storeId, order.user_id, `Pesanan ${order.order_number} ${statusMsg}`]
    );

    return successResponse(
      res,
      { id, order_number: order.order_number, new_status: status },
      `Status pesanan berhasil diperbarui menjadi '${status}'.`
    );
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getOrders,
  getOrderById,
  createOrder,
  updateOrderStatus,
};
