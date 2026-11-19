const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/notifications
 */
async function getNotifications(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const userId = req.user.userId;

    const [rows] = await pool.query(
      `SELECT id, store_id, user_id, title, message, type, is_read, created_at
       FROM notifications
       WHERE store_id = ? AND (user_id IS NULL OR user_id = ?)
       ORDER BY created_at DESC
       LIMIT 30`,
      [storeId, userId]
    );

    return successResponse(res, rows, 'Daftar notifikasi berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * PATCH /api/v1/notifications/:id/read
 */
async function markAsRead(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [result] = await pool.query(
      'UPDATE notifications SET is_read = 1 WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (result.affectedRows === 0) {
      return errorResponse(res, 'Notifikasi tidak ditemukan.', 404);
    }

    return successResponse(res, null, 'Notifikasi telah ditandai dibaca.');
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getNotifications,
  markAsRead,
};
