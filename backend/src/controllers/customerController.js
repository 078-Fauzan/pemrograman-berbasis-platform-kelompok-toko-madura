const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/customers
 */
async function getCustomers(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { search } = req.query;

    let query = `
      SELECT c.id, c.store_id, c.customer_name, c.phone, c.address, c.created_at,
             COUNT(s.id) AS total_orders,
             COALESCE(SUM(s.total), 0) AS total_spend
      FROM customers c
      LEFT JOIN sales s ON c.id = s.customer_id AND s.status = 'completed'
      WHERE c.store_id = ?
    `;
    const params = [storeId];

    if (search) {
      query += ' AND (c.customer_name LIKE ? OR c.phone LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' GROUP BY c.id ORDER BY c.customer_name ASC';

    const [rows] = await pool.query(query, params);
    return successResponse(res, rows, 'Daftar pelanggan berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/customers
 */
async function createCustomer(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { customer_name, phone = null, address = null } = req.body;

    if (!customer_name || customer_name.trim().length === 0) {
      return errorResponse(res, 'Nama pelanggan wajib diisi.', 400);
    }

    const [result] = await pool.query(
      `INSERT INTO customers (store_id, customer_name, phone, address, created_at)
       VALUES (?, ?, ?, ?, NOW())`,
      [storeId, customer_name.trim(), phone?.trim() || null, address?.trim() || null]
    );

    return successResponse(
      res,
      {
        id: result.insertId,
        store_id: storeId,
        customer_name: customer_name.trim(),
        phone: phone?.trim() || null,
        address: address?.trim() || null,
      },
      'Pelanggan berhasil ditambahkan.',
      201
    );
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/customers/:id
 */
async function updateCustomer(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { customer_name, phone, address } = req.body;

    if (!customer_name || customer_name.trim().length === 0) {
      return errorResponse(res, 'Nama pelanggan wajib diisi.', 400);
    }

    const [result] = await pool.query(
      `UPDATE customers 
       SET customer_name = ?, phone = ?, address = ?
       WHERE id = ? AND store_id = ?`,
      [customer_name.trim(), phone?.trim() || null, address?.trim() || null, id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Pelanggan tidak ditemukan.', 404);
    }

    return successResponse(res, { id: Number(id), customer_name, phone, address }, 'Data pelanggan berhasil diperbarui.');
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/v1/customers/:id
 */
async function deleteCustomer(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM customers WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Pelanggan tidak ditemukan.', 404);
    }

    return successResponse(res, null, 'Data pelanggan berhasil dihapus.');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCustomers,
  createCustomer,
  updateCustomer,
  deleteCustomer,
};
