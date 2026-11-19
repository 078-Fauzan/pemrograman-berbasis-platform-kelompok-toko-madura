const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/categories
 */
async function getCategories(req, res, next) {
  try {
    const storeId = req.user.storeId;

    const [categories] = await pool.query(
      `SELECT c.id, c.store_id, c.category_name, c.created_at,
              COUNT(p.id) AS total_products
       FROM categories c
       LEFT JOIN products p ON c.id = p.category_id AND p.is_active = 1
       WHERE c.store_id = ?
       GROUP BY c.id
       ORDER BY c.category_name ASC`,
      [storeId]
    );

    return successResponse(res, categories, 'Daftar kategori berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/categories (Owner only)
 */
async function createCategory(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { category_name } = req.body;

    if (!category_name || category_name.trim().length === 0) {
      return errorResponse(res, 'Nama kategori wajib diisi.', 422);
    }

    const [result] = await pool.query(
      'INSERT INTO categories (store_id, category_name, created_at) VALUES (?, ?, NOW())',
      [storeId, category_name.trim()]
    );

    return successResponse(
      res,
      {
        id: result.insertId,
        store_id: storeId,
        category_name: category_name.trim(),
      },
      'Kategori berhasil ditambahkan.',
      201
    );
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/categories/:id (Owner only)
 */
async function updateCategory(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const { category_name } = req.body;

    if (!category_name || category_name.trim().length === 0) {
      return errorResponse(res, 'Nama kategori wajib diisi.', 422);
    }

    const [result] = await pool.query(
      'UPDATE categories SET category_name = ? WHERE id = ? AND store_id = ?',
      [category_name.trim(), id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Kategori tidak ditemukan pada toko ini.', 404);
    }

    return successResponse(
      res,
      { id: Number(id), store_id: storeId, category_name: category_name.trim() },
      'Kategori berhasil diperbarui.'
    );
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/v1/categories/:id (Owner only)
 */
async function deleteCategory(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM categories WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Kategori tidak ditemukan pada toko ini.', 404);
    }

    return successResponse(res, null, 'Kategori berhasil dihapus.');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getCategories,
  createCategory,
  updateCategory,
  deleteCategory,
};
