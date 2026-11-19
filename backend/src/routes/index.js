const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const userRoutes = require('./userRoutes');
const categoryRoutes = require('./categoryRoutes');
const productRoutes = require('./productRoutes');
const dashboardRoutes = require('./dashboardRoutes');
const notificationRoutes = require('./notificationRoutes');
const orderRoutes = require('./orderRoutes');
const salesRoutes = require('./salesRoutes');
const expenseRoutes = require('./expenseRoutes');
const customerRoutes = require('./customerRoutes');
const supplierRoutes = require('./supplierRoutes');

// Daftarkan sub-routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/categories', categoryRoutes);
router.use('/products', productRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/notifications', notificationRoutes);
router.use('/orders', orderRoutes);
router.use('/sales', salesRoutes);
router.use('/expenses', expenseRoutes);
router.use('/customers', customerRoutes);
router.use('/suppliers', supplierRoutes);

// Endpoint Health Check API
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'UMKMate REST API v1 aktif dan berjalan normal.',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
