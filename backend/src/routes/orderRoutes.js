const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

router.use(authenticate);

// Ambil daftar pesanan (Customer melihat miliknya, Admin/Kasir melihat seluruh toko)
router.get('/', orderController.getOrders);

// Ambil rincian detail 1 pesanan
router.get('/:id', orderController.getOrderById);

// Buat pesanan baru (Customer/Admin/Kasir)
router.post('/', orderController.createOrder);

// Update status pesanan (Hanya Admin, Owner, dan Kasir)
router.patch('/:id/status', requireRole('owner', 'admin', 'cashier'), orderController.updateOrderStatus);

module.exports = router;
