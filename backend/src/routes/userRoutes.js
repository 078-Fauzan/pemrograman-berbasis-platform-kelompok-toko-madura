const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const {
  createCashierValidator,
  updateCashierValidator,
  updateStatusValidator,
} = require('../validators/userValidator');
const { handleValidationErrors } = require('../middleware/validateMiddleware');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

// Seluruh rute manajemen pengguna wajib diautentikasi dan hanya boleh diakses oleh OWNER / ADMIN
router.use(authenticate);
router.use(requireRole('owner', 'admin'));

router.get('/', userController.getUsers);
router.post('/', createCashierValidator, handleValidationErrors, userController.createUser);
router.get('/:id', userController.getUserById);
router.put('/:id', updateCashierValidator, handleValidationErrors, userController.updateUser);
router.patch('/:id/status', updateStatusValidator, handleValidationErrors, userController.updateUserStatus);

module.exports = router;
