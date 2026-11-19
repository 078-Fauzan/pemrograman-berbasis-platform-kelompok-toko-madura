const { pool } = require('../config/database');
const { successResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/dashboard (Ringkasan KPI Dashboard Utama)
 */
async function getSummary(req, res, next) {
  try {
    const storeId = req.user.storeId;

    // 1. Total penjualan hari ini & jumlah transaksi hari ini
    const [salesToday] = await pool.query(
      `SELECT COALESCE(SUM(total), 0) AS total_sales,
              COUNT(id) AS total_transactions
       FROM sales
       WHERE store_id = ? AND sale_date = CURDATE() AND status = 'completed'`,
      [storeId]
    );

    // 2. Total produk aktif
    const [productCount] = await pool.query(
      'SELECT COUNT(id) AS total_products FROM products WHERE store_id = ? AND is_active = 1',
      [storeId]
    );

    // 3. Jumlah produk dengan stok menipis (stock <= minimum_stock)
    const [lowStockCount] = await pool.query(
      'SELECT COUNT(id) AS low_stock_count FROM products WHERE store_id = ? AND is_active = 1 AND stock <= minimum_stock',
      [storeId]
    );

    // 4. Total pengeluaran hari ini
    const [expenseToday] = await pool.query(
      'SELECT COALESCE(SUM(amount), 0) AS total_expense FROM expenses WHERE store_id = ? AND expense_date = CURDATE()',
      [storeId]
    );

    return successResponse(
      res,
      {
        sales_today: Number(salesToday[0].total_sales),
        transactions_today: Number(salesToday[0].total_transactions),
        total_products: Number(productCount[0].total_products),
        low_stock_products: Number(lowStockCount[0].low_stock_count),
        expenses_today: Number(expenseToday[0].total_expense),
      },
      'Ringkasan dashboard berhasil diambil.'
    );
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/dashboard/sales-chart (Data 7 hari terakhir untuk fl_chart)
 */
async function getSalesChart(req, res, next) {
  try {
    const storeId = req.user.storeId;

    // Ambil penjualan 7 hari terakhir
    const [rows] = await pool.query(
      `SELECT DATE_FORMAT(sale_date, '%Y-%m-%d') AS date,
              DATE_FORMAT(sale_date, '%d/%m') AS formatted_date,
              COALESCE(SUM(total), 0) AS total_amount,
              COUNT(id) AS transaction_count
       FROM sales
       WHERE store_id = ? 
         AND sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
         AND status = 'completed'
       GROUP BY sale_date
       ORDER BY sale_date ASC`,
      [storeId]
    );

    return successResponse(res, rows, 'Data grafik penjualan berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/dashboard/transaction-stats
 */
async function getTransactionStats(req, res, next) {
  try {
    const storeId = req.user.storeId;

    // Statistik transaksi & breakdown metode pembayaran
    const [methodStats] = await pool.query(
      `SELECT p.payment_method,
              COUNT(p.id) AS count,
              COALESCE(SUM(p.amount), 0) AS total_amount
       FROM payments p
       JOIN sales s ON p.sale_id = s.id
       WHERE s.store_id = ? AND s.status = 'completed'
       GROUP BY p.payment_method`,
      [storeId]
    );

    const [aovRows] = await pool.query(
      `SELECT COALESCE(AVG(total), 0) AS average_order_value,
              COALESCE(SUM(total), 0) AS total_revenue,
              COUNT(id) AS total_completed_sales
       FROM sales
       WHERE store_id = ? AND status = 'completed'`,
      [storeId]
    );

    return successResponse(
      res,
      {
        average_order_value: Number(aovRows[0].average_order_value),
        total_revenue: Number(aovRows[0].total_revenue),
        total_transactions: Number(aovRows[0].total_completed_sales),
        payment_methods: methodStats,
      },
      'Statistik transaksi berhasil diambil.'
    );
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/dashboard/best-selling (Top 5 Produk Terlaris)
 */
async function getBestSelling(req, res, next) {
  try {
    const storeId = req.user.storeId;

    const [rows] = await pool.query(
      `SELECT p.id, p.product_name, p.unit, p.selling_price,
              COALESCE(SUM(si.quantity), 0) AS total_sold,
              COALESCE(SUM(si.subtotal), 0) AS total_revenue
       FROM sale_items si
       JOIN sales s ON si.sale_id = s.id
       JOIN products p ON si.product_id = p.id
       WHERE s.store_id = ? AND s.status = 'completed'
       GROUP BY p.id
       ORDER BY total_sold DESC
       LIMIT 5`,
      [storeId]
    );

    return successResponse(res, rows, 'Daftar produk terlaris berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/dashboard/financial-report (Laporan Keuangan & Laba Kotor Toko)
 */
async function getFinancialReport(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { period = 'month', start_date, end_date } = req.query;

    let dateCondition = '';
    const dateParams = [];

    if (start_date && end_date) {
      dateCondition = 'AND s.sale_date BETWEEN ? AND ?';
      dateParams.push(start_date, end_date);
    } else if (period === 'today') {
      dateCondition = 'AND s.sale_date = CURDATE()';
    } else if (period === 'week') {
      dateCondition = 'AND s.sale_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)';
    } else if (period === 'month') {
      dateCondition = 'AND s.sale_date >= DATE_FORMAT(CURDATE(), "%Y-%m-01")';
    } else if (period === 'year') {
      dateCondition = 'AND s.sale_date >= DATE_FORMAT(CURDATE(), "%Y-01-01")';
    }

    // 1. Total Penjualan & Diskon
    const [salesRows] = await pool.query(
      `SELECT COALESCE(SUM(s.total), 0) AS total_revenue,
              COALESCE(SUM(s.subtotal), 0) AS total_subtotal,
              COALESCE(SUM(s.discount), 0) AS total_discount,
              COUNT(s.id) AS total_transactions
       FROM sales s
       WHERE s.store_id = ? AND s.status = 'completed' ${dateCondition}`,
      [storeId, ...dateParams]
    );

    // 2. Total HPP (Cost of Goods Sold) dari snapshot unit_cost
    const [cogsRows] = await pool.query(
      `SELECT COALESCE(SUM(si.quantity * si.unit_cost), 0) AS total_cogs
       FROM sale_items si
       JOIN sales s ON si.sale_id = s.id
       WHERE s.store_id = ? AND s.status = 'completed' ${dateCondition}`,
      [storeId, ...dateParams]
    );

    // 3. Pengeluaran Operasional
    let expenseDateCond = '';
    const expenseDateParams = [];
    if (start_date && end_date) {
      expenseDateCond = 'AND expense_date BETWEEN ? AND ?';
      expenseDateParams.push(start_date, end_date);
    } else if (period === 'today') {
      expenseDateCond = 'AND expense_date = CURDATE()';
    } else if (period === 'week') {
      expenseDateCond = 'AND expense_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)';
    } else if (period === 'month') {
      expenseDateCond = 'AND expense_date >= DATE_FORMAT(CURDATE(), "%Y-%m-01")';
    } else if (period === 'year') {
      expenseDateCond = 'AND expense_date >= DATE_FORMAT(CURDATE(), "%Y-01-01")';
    }

    const [expenseRows] = await pool.query(
      `SELECT COALESCE(SUM(amount), 0) AS total_expenses,
              COUNT(id) AS total_expense_count
       FROM expenses
       WHERE store_id = ? ${expenseDateCond}`,
      [storeId, ...expenseDateParams]
    );

    // 4. Breakdown Pengeluaran per Kategori
    const [expenseCategories] = await pool.query(
      `SELECT COALESCE(ec.category_name, 'Lain-lain') AS category_name,
              COALESCE(SUM(e.amount), 0) AS total_amount
       FROM expenses e
       LEFT JOIN expense_categories ec ON e.category_id = ec.id
       WHERE e.store_id = ? ${expenseDateCond}
       GROUP BY ec.id, ec.category_name
       ORDER BY total_amount DESC`,
      [storeId, ...expenseDateParams]
    );

    const totalRevenue = Number(salesRows[0].total_revenue);
    const totalSubtotal = Number(salesRows[0].total_subtotal);
    const totalDiscount = Number(salesRows[0].total_discount);
    const totalTransactions = Number(salesRows[0].total_transactions);
    const totalCogs = Number(cogsRows[0].total_cogs);
    const totalExpenses = Number(expenseRows[0].total_expenses);
    const grossProfit = totalRevenue - totalCogs;
    const grossMarginPct = totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;
    const netProfit = grossProfit - totalExpenses;

    return successResponse(
      res,
      {
        period,
        revenue: totalRevenue,
        subtotal: totalSubtotal,
        discount: totalDiscount,
        transactions: totalTransactions,
        cogs: totalCogs,
        gross_profit: grossProfit,
        gross_margin_percentage: Math.round(grossMarginPct * 10) / 10,
        expenses: totalExpenses,
        net_profit: netProfit,
        expense_categories: expenseCategories,
      },
      'Laporan keuangan berhasil diambil.'
    );
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getSummary,
  getSalesChart,
  getTransactionStats,
  getBestSelling,
  getFinancialReport,
};
