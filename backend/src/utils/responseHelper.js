/**
 * Format standar response JSON sukses
 */
function successResponse(res, data = null, message = 'Berhasil', statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

/**
 * Format standar response JSON error
 */
function errorResponse(res, message = 'Terjadi kesalahan sistem', statusCode = 500, errors = null) {
  const payload = {
    success: false,
    message,
  };

  if (errors) {
    payload.errors = errors;
  }

  return res.status(statusCode).json(payload);
}

/**
 * Format standar response paginasi data
 */
function paginationResponse(res, items = [], pagination = {}, message = 'Berhasil mengambil data') {
  return res.status(200).json({
    success: true,
    message,
    data: {
      items,
      pagination: {
        total: pagination.total || items.length,
        page: pagination.page || 1,
        limit: pagination.limit || items.length,
        totalPages: pagination.totalPages || 1,
      },
    },
  });
}

module.exports = {
  successResponse,
  errorResponse,
  paginationResponse,
};
