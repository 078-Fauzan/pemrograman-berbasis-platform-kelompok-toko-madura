const { validationResult } = require('express-validator');
const { errorResponse } = require('../utils/responseHelper');

/**
 * Middleware untuk mengevaluasi hasil validasi express-validator
 */
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const formattedErrors = errors.array().map((err) => ({
      field: err.path || err.param,
      message: err.msg,
      value: err.value,
    }));

    return errorResponse(res, 'Validasi input gagal. Silakan periksa kembali data Anda.', 422, formattedErrors);
  }
  next();
}

module.exports = {
  handleValidationErrors,
};
