const config = require('../config/env');
const { errorResponse } = require('../utils/responseHelper');

/**
 * Global Centralized Error Handler Middleware
 */
function errorHandler(err, req, res, next) {
  console.error('[Unhandled Error]', {
    path: req.originalUrl,
    method: req.method,
    message: err.message,
    stack: config.env === 'development' ? err.stack : undefined,
  });

  // Tangani kesalahan spesifik MySQL
  if (err.code === 'ER_DUP_ENTRY') {
    return errorResponse(res, 'Data sudah terdaftar dalam sistem (duplikasi entri).', 409);
  }

  if (err.code === 'ER_NO_REFERENCED_ROW_2' || err.code === 'ER_NO_REFERENCED_ROW') {
    return errorResponse(res, 'Referensi data relasi tidak ditemukan.', 400);
  }

  if (err.code === 'ER_ROW_IS_REFERENCED_2') {
    return errorResponse(res, 'Data tidak dapat dihapus karena masih digunakan dalam riwayat transaksi.', 400);
  }

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Terjadi kesalahan internal pada server.';

  return errorResponse(
    res,
    message,
    statusCode,
    config.env === 'development' ? { stack: err.stack } : null
  );
}

module.exports = {
  errorHandler,
};
