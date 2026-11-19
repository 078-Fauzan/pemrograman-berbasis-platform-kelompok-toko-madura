const { body } = require('express-validator');

const registerValidator = [
  body('store_name')
    .trim()
    .notEmpty()
    .withMessage('Nama toko wajib diisi')
    .isLength({ min: 3 })
    .withMessage('Nama toko minimal 3 karakter'),
  body('owner_name')
    .trim()
    .notEmpty()
    .withMessage('Nama pemilik toko wajib diisi')
    .isLength({ min: 3 })
    .withMessage('Nama pemilik minimal 3 karakter'),
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email wajib diisi')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Nomor telepon wajib diisi')
    .isLength({ min: 8, max: 20 })
    .withMessage('Nomor telepon harus antara 8 - 20 digit'),
  body('password')
    .notEmpty()
    .withMessage('Password wajib diisi')
    .isLength({ min: 6 })
    .withMessage('Password minimal 6 karakter'),
  body('address')
    .optional()
    .trim(),
];

const loginValidator = [
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email wajib diisi')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('password')
    .notEmpty()
    .withMessage('Password wajib diisi'),
];

const forgotPasswordValidator = [
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email wajib diisi')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
];

const resetPasswordValidator = [
  body('token')
    .notEmpty()
    .withMessage('Token reset password wajib disertakan'),
  body('new_password')
    .notEmpty()
    .withMessage('Password baru wajib diisi')
    .isLength({ min: 6 })
    .withMessage('Password baru minimal 6 karakter'),
];

const updateProfileValidator = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2 })
    .withMessage('Nama minimal 2 karakter'),
  body('phone')
    .optional()
    .trim(),
  body('store_name')
    .optional()
    .trim()
    .isLength({ min: 3 })
    .withMessage('Nama toko minimal 3 karakter'),
  body('address')
    .optional()
    .trim(),
];

const registerCustomerValidator = [
  body('name')
    .trim()
    .notEmpty()
    .withMessage('Nama lengkap wajib diisi')
    .isLength({ min: 2 })
    .withMessage('Nama minimal 2 karakter'),
  body('email')
    .trim()
    .notEmpty()
    .withMessage('Email wajib diisi')
    .isEmail()
    .withMessage('Format email tidak valid')
    .normalizeEmail(),
  body('phone')
    .trim()
    .notEmpty()
    .withMessage('Nomor telepon/WA wajib diisi')
    .isLength({ min: 8, max: 20 })
    .withMessage('Nomor telepon harus antara 8 - 20 digit'),
  body('password')
    .notEmpty()
    .withMessage('Password wajib diisi')
    .isLength({ min: 6 })
    .withMessage('Password minimal 6 karakter'),
  body('address')
    .optional()
    .trim(),
];

module.exports = {
  registerValidator,
  registerCustomerValidator,
  loginValidator,
  forgotPasswordValidator,
  resetPasswordValidator,
  updateProfileValidator,
};
