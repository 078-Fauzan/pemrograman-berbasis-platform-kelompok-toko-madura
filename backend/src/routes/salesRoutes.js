const express = require('express');
const router = express.Router();
const salesController = require('../controllers/salesController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

// Seluruh rute sales memerlukan autentikasi
router.use(authenticate);

// Buat transaksi kasir (Owner, Admin, Kasir)
router.post('/', requireRole(['owner', 'admin', 'cashier']), salesController.createSale);

// Riwayat transaksi (Owner, Admin, Kasir)
router.get('/', requireRole(['owner', 'admin', 'cashier']), salesController.getSales);

// Detail transaksi (Owner, Admin, Kasir)
router.get('/:id', requireRole(['owner', 'admin', 'cashier']), salesController.getSaleById);

// Batalkan penjualan / Void (Owner, Admin only)
router.patch('/:id/void', requireRole(['owner', 'admin']), salesController.voidSale);

module.exports = router;
