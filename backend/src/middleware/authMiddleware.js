const { verifyToken } = require('../utils/tokenHelper');
const { errorResponse } = require('../utils/responseHelper');
const { pool } = require('../config/database');

/**
 * Middleware untuk memvalidasi token JWT dan memastikan pengguna aktif
 */
async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return errorResponse(res, 'Akses ditolak. Token autentikasi tidak ditemukan.', 401);
    }

    const token = authHeader.split(' ')[1];
    const decoded = verifyToken(token);

    if (!decoded) {
      return errorResponse(res, 'Sesi tidak valid atau telah kedaluwarsa. Silakan login kembali.', 401);
    }

    // Ambil data user aktif langsung dari database untuk memastikan akun belum dinonaktifkan
    const [rows] = await pool.query(
      'SELECT id, store_id, name, email, role, is_active FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (rows.length === 0) {
      return errorResponse(res, 'Akun pengguna tidak ditemukan.', 401);
    }

    const user = rows[0];

    if (!user.is_active) {
      return errorResponse(res, 'Akun Anda telah dinonaktifkan oleh pemilik toko.', 403);
    }

    // Sematkan klaim identitas ke objek req.user
    req.user = {
      userId: user.id,
      storeId: user.store_id,
      role: user.role,
      email: user.email,
      name: user.name,
    };

    next();
  } catch (error) {
    return errorResponse(res, 'Gagal memverifikasi token autentikasi: ' + error.message, 401);
  }
}

module.exports = {
  authenticate,
};
