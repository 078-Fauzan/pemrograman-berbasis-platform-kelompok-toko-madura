const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');
const { generateInvoiceNumber } = require('../utils/invoiceGenerator');

/**
 * POST /api/v1/sales (Proses Checkout Kasir POS dengan Transaksi ACID)
 */
async function createSale(req, res, next) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const storeId = req.user.storeId;
    const cashierId = req.user.userId;
    const {
      customer_id = null,
      discount = 0,
      items = [],
      payment = {},
    } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      await connection.rollback();
      return errorResponse(res, 'Transaksi harus memuat minimal 1 produk.', 400);
    }

    const discountAmount = Math.max(0, parseFloat(discount) || 0);
    const paymentMethod = payment.payment_method || 'cash';

    // Kumpulkan seluruh Product ID untuk dicek dan dikunci (Pessimistic Locking)
    const productIds = items.map((i) => parseInt(i.product_id, 10));
    const [dbProducts] = await connection.query(
      `SELECT id, product_name, cost_price, selling_price, stock, minimum_stock, is_active 
       FROM products 
       WHERE id IN (?) AND store_id = ? 
       FOR UPDATE`,
      [productIds, storeId]
    );

    const productMap = new Map();
    dbProducts.forEach((p) => productMap.set(p.id, p));

    // Validasi ketersediaan dan stok tiap item belanja
    let calculatedSubtotal = 0;
    const verifiedSaleItems = [];

    for (const item of items) {
      const pId = parseInt(item.product_id, 10);
      const qty = parseInt(item.quantity, 10);

      if (isNaN(qty) || qty <= 0) {
        await connection.rollback();
        return errorResponse(res, 'Jumlah barang (kuantitas) harus lebih besar dari 0.', 400);
      }

      const prod = productMap.get(pId);
      if (!prod || !prod.is_active) {
        await connection.rollback();
        return errorResponse(res, `Produk ID #${pId} tidak ditemukan atau sudah dinonaktifkan.`, 400);
      }

      if (prod.stock < qty) {
        await connection.rollback();
        return errorResponse(
          res,
          `Stok produk '${prod.product_name}' tidak mencukupi (Sisa: ${prod.stock}, diminta: ${qty}).`,
          400
        );
      }

      const sellingPrice = parseFloat(prod.selling_price);
      const unitCost = parseFloat(prod.cost_price || 0);
      const itemSubtotal = sellingPrice * qty;
      calculatedSubtotal += itemSubtotal;

      verifiedSaleItems.push({
        product_id: prod.id,
        product_name: prod.product_name,
        selling_price: sellingPrice,
        unit_cost: unitCost,
        quantity: qty,
        subtotal: itemSubtotal,
        current_stock: prod.stock,
        minimum_stock: prod.minimum_stock,
      });
    }

    const calculatedTotal = Math.max(0, calculatedSubtotal - discountAmount);
    const cashReceived = paymentMethod === 'cash'
      ? parseFloat(payment.cash_received || calculatedTotal)
      : calculatedTotal;

    if (paymentMethod === 'cash' && cashReceived < calculatedTotal) {
      await connection.rollback();
      return errorResponse(
        res,
        `Uang tunai yang diterima (Rp ${cashReceived.toLocaleString('id-ID')}) kurang dari total belanja (Rp ${calculatedTotal.toLocaleString('id-ID')}).`,
        400
      );
    }

    const changeAmount = paymentMethod === 'cash'
      ? Math.max(0, cashReceived - calculatedTotal)
      : 0;

    // Generate Invoice Number
    const invoiceNumber = generateInvoiceNumber();

    // 1. Simpan Transaksi Penjualan Utama
    const [saleResult] = await connection.query(
      `INSERT INTO sales 
       (store_id, customer_id, cashier_id, invoice_number, subtotal, discount, total, status, sale_date, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'completed', CURDATE(), NOW())`,
      [
        storeId,
        customer_id || null,
        cashierId,
        invoiceNumber,
        calculatedSubtotal,
        discountAmount,
        calculatedTotal,
      ]
    );

    const saleId = saleResult.insertId;

    // 2. Simpan Rincian Item Penjualan & Kurangi Stok Fisik
    for (const item of verifiedSaleItems) {
      // Simpan rincian item dengan snapshot HPP (unit_cost)
      await connection.query(
        `INSERT INTO sale_items 
         (sale_id, product_id, quantity, selling_price, unit_cost, subtotal)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          saleId,
          item.product_id,
          item.quantity,
          item.selling_price,
          item.unit_cost,
          item.subtotal,
        ]
      );

      // Kurangi stok produk
      const stockAfter = item.current_stock - item.quantity;
      await connection.query(
        'UPDATE products SET stock = ? WHERE id = ? AND store_id = ?',
        [stockAfter, item.product_id, storeId]
      );

      // Catat ke riwayat mutasi stok
      await connection.query(
        `INSERT INTO stock_movements 
         (store_id, product_id, user_id, movement_type, quantity, stock_before, stock_after, reference_type, reference_id, notes, created_at)
         VALUES (?, ?, ?, 'sale', ?, ?, ?, 'sale', ?, 'Penjualan Kasir POS', NOW())`,
        [
          storeId,
          item.product_id,
          cashierId,
          item.quantity,
          item.current_stock,
          stockAfter,
          saleId,
        ]
      );

      // Notifikasi otomatis jika stok menipis
      if (stockAfter <= item.minimum_stock) {
        await connection.query(
          `INSERT INTO notifications (store_id, user_id, title, message, type, is_read, created_at)
           VALUES (?, NULL, 'Peringatan Stok Menipis!', ?, 'stock_alert', 0, NOW())`,
          [
            storeId,
            `Stok '${item.product_name}' tersisa ${stockAfter} item (di bawah batas minimum ${item.minimum_stock}). Segera lakukan restock.`,
          ]
        );
      }
    }

    // 3. Catat Pembayaran
    await connection.query(
      `INSERT INTO payments 
       (sale_id, received_by, payment_method, amount, cash_received, change_amount, created_at)
       VALUES (?, ?, ?, ?, ?, ?, NOW())`,
      [
        saleId,
        cashierId,
        paymentMethod,
        calculatedTotal,
        cashReceived,
        changeAmount,
      ]
    );

    // 4. Catat Log Aktivitas
    await connection.query(
      `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
       VALUES (?, ?, 'CREATE_SALE', ?, NOW())`,
      [
        storeId,
        cashierId,
        `Penjualan ${invoiceNumber} senilai Rp ${calculatedTotal.toLocaleString('id-ID')} berhasil diproses.`,
      ]
    );

    await connection.commit();

    return successResponse(
      res,
      {
        sale_id: saleId,
        invoice_number: invoiceNumber,
        subtotal: calculatedSubtotal,
        discount: discountAmount,
        total: calculatedTotal,
        payment_method: paymentMethod,
        cash_received: cashReceived,
        change_amount: changeAmount,
        items_count: verifiedSaleItems.length,
        items: verifiedSaleItems,
        created_at: new Date().toISOString(),
      },
      'Transaksi kasir berhasil disimpan.',
      201
    );
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

/**
 * GET /api/v1/sales (Riwayat Transaksi Penjualan)
 */
async function getSales(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const isOwner = req.user.role === 'owner' || req.user.role === 'admin';
    const { date, start_date, end_date, status, search, cashier_id } = req.query;

    let query = `
      SELECT s.id, s.store_id, s.customer_id, s.cashier_id, s.invoice_number,
             s.subtotal, s.discount, s.total, s.status, s.sale_date, s.created_at,
             u.name AS cashier_name,
             p.payment_method, p.cash_received, p.change_amount,
             COUNT(si.id) AS total_items,
             COALESCE(SUM(si.quantity), 0) AS total_qty
      FROM sales s
      JOIN users u ON s.cashier_id = u.id
      LEFT JOIN payments p ON s.id = p.sale_id
      LEFT JOIN sale_items si ON s.id = si.sale_id
      WHERE s.store_id = ?
    `;
    const params = [storeId];

    // Kasir hanya melihat transaksinya sendiri jika bukan owner/admin
    if (!isOwner) {
      query += ' AND s.cashier_id = ?';
      params.push(req.user.userId);
    } else if (cashier_id) {
      query += ' AND s.cashier_id = ?';
      params.push(cashier_id);
    }

    if (date) {
      query += ' AND s.sale_date = ?';
      params.push(date);
    }

    if (start_date && end_date) {
      query += ' AND s.sale_date BETWEEN ? AND ?';
      params.push(start_date, end_date);
    }

    if (status) {
      query += ' AND s.status = ?';
      params.push(status);
    }

    if (search) {
      query += ' AND s.invoice_number LIKE ?';
      params.push(`%${search}%`);
    }

    query += ' GROUP BY s.id ORDER BY s.created_at DESC';

    const [rows] = await pool.query(query, params);
    return successResponse(res, rows, 'Daftar riwayat transaksi berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/sales/:id (Detail Transaksi Penjualan)
 */
async function getSaleById(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    const [sales] = await pool.query(
      `SELECT s.id, s.store_id, s.customer_id, s.cashier_id, s.invoice_number,
              s.subtotal, s.discount, s.total, s.status, s.sale_date, s.created_at,
              u.name AS cashier_name,
              p.payment_method, p.cash_received, p.change_amount
       FROM sales s
       JOIN users u ON s.cashier_id = u.id
       LEFT JOIN payments p ON s.id = p.sale_id
       WHERE s.id = ? AND s.store_id = ?`,
      [id, storeId]
    );

    if (sales.length === 0) {
      return errorResponse(res, 'Transaksi penjualan tidak ditemukan.', 404);
    }

    const sale = sales[0];

    // Ambil rincian produk
    const [items] = await pool.query(
      `SELECT si.id, si.product_id, si.quantity, si.selling_price, si.unit_cost, si.subtotal,
              p.product_name, p.barcode, p.unit
       FROM sale_items si
       JOIN products p ON si.product_id = p.id
       WHERE si.sale_id = ?`,
      [sale.id]
    );

    sale.items = items;
    return successResponse(res, sale, 'Detail transaksi berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * PATCH /api/v1/sales/:id/void (Batalkan Penjualan / Void - Owner only)
 */
async function voidSale(req, res, next) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const storeId = req.user.storeId;
    const userId = req.user.userId;
    const { id } = req.params;
    const { reason = 'Dibatalkan oleh pemilik' } = req.body;

    const [sales] = await connection.query(
      'SELECT id, invoice_number, status FROM sales WHERE id = ? AND store_id = ? FOR UPDATE',
      [id, storeId]
    );

    if (sales.length === 0) {
      await connection.rollback();
      return errorResponse(res, 'Transaksi tidak ditemukan.', 404);
    }

    const sale = sales[0];
    if (sale.status === 'voided') {
      await connection.rollback();
      return errorResponse(res, 'Transaksi ini sudah pernah dibatalkan (voided).', 400);
    }

    // Ambil item untuk mengembalikan stok
    const [items] = await connection.query(
      'SELECT product_id, quantity FROM sale_items WHERE sale_id = ?',
      [sale.id]
    );

    for (const item of items) {
      // Ambil stok saat ini
      const [prod] = await connection.query(
        'SELECT stock FROM products WHERE id = ? FOR UPDATE',
        [item.product_id]
      );
      const stockBefore = prod[0].stock;
      const stockAfter = stockBefore + item.quantity;

      await connection.query(
        'UPDATE products SET stock = ? WHERE id = ?',
        [stockAfter, item.product_id]
      );

      await connection.query(
        `INSERT INTO stock_movements 
         (store_id, product_id, user_id, movement_type, quantity, stock_before, stock_after, reference_type, reference_id, notes, created_at)
         VALUES (?, ?, ?, 'void', ?, ?, ?, 'sale_void', ?, ?, NOW())`,
        [
          storeId,
          item.product_id,
          userId,
          item.quantity,
          stockBefore,
          stockAfter,
          sale.id,
          `Void Nota ${sale.invoice_number}: ${reason}`,
        ]
      );
    }

    // Update status penjualan
    await connection.query(
      "UPDATE sales SET status = 'voided' WHERE id = ?",
      [sale.id]
    );

    // Catat log aktivitas
    await connection.query(
      `INSERT INTO activity_logs (store_id, user_id, activity, description, created_at)
       VALUES (?, ?, 'VOID_SALE', ?, NOW())`,
      [storeId, userId, `Nota ${sale.invoice_number} dibatalkan (void). Alasan: ${reason}`]
    );

    await connection.commit();
    return successResponse(res, { id: sale.id, invoice_number: sale.invoice_number, status: 'voided' }, 'Transaksi berhasil dibatalkan dan stok dikembalikan.');
  } catch (error) {
    await connection.rollback();
    next(error);
  } finally {
    connection.release();
  }
}

module.exports = {
  createSale,
  getSales,
  getSaleById,
  voidSale,
};
