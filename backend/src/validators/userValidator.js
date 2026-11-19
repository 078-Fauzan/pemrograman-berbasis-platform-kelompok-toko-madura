const { body, param } = require('express-validator');

const createCashierValidator = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Nama kasir wajib diisi')
    .isLength({ min: 2 })
    .withMessage('Nama kasir minimal 2 karakter'),
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email kasir wajib diisi')
    .isEmail()
    .withMessage('Format email kasir tidak valid')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password kasir wajib diisi')
    .isLength({ min: 6 })
    .withMessage('Password minimal 6 karakter'),
  body('phone')
    .optional()
    .trim()
    .isLength({ min: 8, max: 20 })
    .withMessage('Nomor telepon harus antara 8 - 20 digit'),
];

const updateCashierValidator = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID kasir tidak valid'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Nama kasir minimal 2 karakter'),
  body('phone')
    .optional()
    .trim(),
  body('password')
    .optional()
    .isLength({ min: 6 })
    .withMessage('Password minimal 6 karakter jika ingin diubah'),
];

const updateStatusValidator = [
  param('id')
    .isInt({ min: 1 })
    .withMessage('ID kasir tidak valid'),
  body('is_active')
    .isBoolean()
    .withMessage('Status is_active wajib bernilai boolean (true/false atau 1/0)'),
];

module.exports = {
  createCashierValidator,
  updateCashierValidator,
  updateStatusValidator,
};
