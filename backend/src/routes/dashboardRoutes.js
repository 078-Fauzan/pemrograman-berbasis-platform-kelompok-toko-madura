const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const { authenticate } = require('../middleware/authMiddleware');
const { requireRole } = require('../middleware/roleMiddleware');

router.use(authenticate);
router.use(requireRole('owner', 'admin'));

router.get('/', dashboardController.getSummary);
router.get('/sales-chart', dashboardController.getSalesChart);
router.get('/transaction-stats', dashboardController.getTransactionStats);
router.get('/best-selling', dashboardController.getBestSelling);
router.get('/financial-report', dashboardController.getFinancialReport);

module.exports = router;
