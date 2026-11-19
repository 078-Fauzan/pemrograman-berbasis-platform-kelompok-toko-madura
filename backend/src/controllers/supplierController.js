const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/suppliers
 */
async function getSuppliers(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { search } = req.query;

    let query = `
      SELECT s.id, s.store_id, s.supplier_name, s.phone, s.address, s.created_at,
             COUNT(p.id) AS total_purchases,
             COALESCE(SUM(p.total), 0) AS total_spent
      FROM suppliers s
      LEFT JOIN purchases p ON s.id = p.supplier_id
      WHERE s.store_id = ?
    `;
    const params = [storeId];

    if (search) {
      query += ' AND (s.supplier_name LIKE ? OR s.phone LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' GROUP BY s.id ORDER BY s.supplier_name ASC';

    const [rows] = await pool.query(query, params);
    return successResponse(res, rows, 'Daftar pemasok berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/suppliers
 */
async function createSupplier(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { supplier_name, phone = null, address = null } = req.body;

    if (!supplier_name || supplier_name.trim().length === 0) {
      return errorResponse(res, 'Nama supplier / pemasok wajib diisi.', 400);
    }

    const [result] = await pool.query(
      `INSERT INTO suppliers (store_id, supplier_name, phone, address, created_at)
       VALUES (?, ?, ?, ?, NOW())`,
      [storeId, supplier_name.trim(), phone?.trim() || null, address?.trim() || null]
    );

    return successResponse(
      res,
      {
        id: result.insertId,
        store_id: storeId,
        supplier_name: supplier_name.trim(),
        phone: phone?.trim() || null,
        address: address?.trim() || null,
      },
      'Pemasok berhasil ditambahkan.',
      201
    );
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/suppliers/:id
 */
async function updateSupplier(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { supplier_name, phone, address } = req.body;

    if (!supplier_name || supplier_name.trim().length === 0) {
      return errorResponse(res, 'Nama supplier / pemasok wajib diisi.', 400);
    }

    const [result] = await pool.query(
      `UPDATE suppliers 
       SET supplier_name = ?, phone = ?, address = ?
       WHERE id = ? AND store_id = ?`,
      [supplier_name.trim(), phone?.trim() || null, address?.trim() || null, id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Pemasok tidak ditemukan.', 404);
    }

    return successResponse(res, { id: Number(id), supplier_name, phone, address }, 'Data pemasok berhasil diperbarui.');
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/v1/suppliers/:id
 */
async function deleteSupplier(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM suppliers WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Pemasok tidak ditemukan.', 404);
    }

    return successResponse(res, null, 'Data pemasok berhasil dihapus.');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getSuppliers,
  createSupplier,
  updateSupplier,
  deleteSupplier,
};
