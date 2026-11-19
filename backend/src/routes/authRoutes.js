const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const {
  registerValidator,
  registerCustomerValidator,
  loginValidator,
  forgotPasswordValidator,
  resetPasswordValidator,
  updateProfileValidator,
} = require('../validators/authValidator');
const { handleValidationErrors } = require('../middleware/validateMiddleware');
const { authenticate } = require('../middleware/authMiddleware');

// Public routes
router.post('/register', registerValidator, handleValidationErrors, authController.register);
router.post('/register-customer', registerCustomerValidator, handleValidationErrors, authController.registerCustomer);
router.post('/login', loginValidator, handleValidationErrors, authController.login);
router.post('/forgot-password', forgotPasswordValidator, handleValidationErrors, authController.forgotPassword);
router.post('/reset-password', resetPasswordValidator, handleValidationErrors, authController.resetPassword);

// Protected routes (membutuhkan Bearer token)
router.get('/me', authenticate, authController.getMe);
router.put('/profile', authenticate, updateProfileValidator, handleValidationErrors, authController.updateProfile);

module.exports = router;
