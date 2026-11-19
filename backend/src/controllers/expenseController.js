const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/expenses (Daftar Pengeluaran Operasional Toko)
 */
async function getExpenses(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { start_date, end_date, category_id } = req.query;

    let query = `
      SELECT e.id, e.store_id, e.category_id, e.user_id, e.description,
             e.amount, e.expense_date, e.created_at,
             COALESCE(ec.category_name, 'Umum') AS category_name,
             u.name AS recorded_by
      FROM expenses e
      LEFT JOIN expense_categories ec ON e.category_id = ec.id
      JOIN users u ON e.user_id = u.id
      WHERE e.store_id = ?
    `;
    const params = [storeId];

    if (start_date && end_date) {
      query += ' AND e.expense_date BETWEEN ? AND ?';
      params.push(start_date, end_date);
    }

    if (category_id) {
      query += ' AND e.category_id = ?';
      params.push(category_id);
    }

    query += ' ORDER BY e.expense_date DESC, e.created_at DESC';

    const [rows] = await pool.query(query, params);
    return successResponse(res, rows, 'Daftar pengeluaran berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/expenses (Catat Pengeluaran Operasional Baru)
 */
async function createExpense(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const userId = req.user.userId;
    const { description, amount, category_id = null, expense_date } = req.body;

    if (!description || description.trim().length === 0) {
      return errorResponse(res, 'Keterangan pengeluaran wajib diisi.', 400);
    }

    const expenseAmount = parseFloat(amount);
    if (isNaN(expenseAmount) || expenseAmount <= 0) {
      return errorResponse(res, 'Jumlah nominal pengeluaran harus lebih besar dari 0.', 400);
    }

    const date = expense_date || new Date().toISOString().slice(0, 10);

    const [result] = await pool.query(
      `INSERT INTO expenses (store_id, category_id, user_id, description, amount, expense_date, created_at)
       VALUES (?, ?, ?, ?, ?, ?, NOW())`,
      [storeId, category_id || null, userId, description.trim(), expenseAmount, date]
    );

    return successResponse(
      res,
      {
        id: result.insertId,
        store_id: storeId,
        category_id: category_id || null,
        description: description.trim(),
        amount: expenseAmount,
        expense_date: date,
      },
      'Pengeluaran berhasil dicatat.',
      201
    );
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/v1/expenses/:id
 */
async function deleteExpense(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [result] = await pool.query(
      'DELETE FROM expenses WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Pengeluaran tidak ditemukan.', 404);
    }

    return successResponse(res, null, 'Data pengeluaran berhasil dihapus.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/expenses/categories
 */
async function getExpenseCategories(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const [rows] = await pool.query(
      'SELECT id, store_id, category_name FROM expense_categories WHERE store_id = ? ORDER BY category_name ASC',
      [storeId]
    );
    return successResponse(res, rows, 'Kategori pengeluaran berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getExpenses,
  createExpense,
  deleteExpense,
  getExpenseCategories,
};
