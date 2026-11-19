const { pool } = require('../config/database');
const { successResponse, errorResponse } = require('../utils/responseHelper');

/**
 * GET /api/v1/products (Mendukung search query & filter kategori)
 */
async function getProducts(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const isOwner = req.user.role === 'owner' || req.user.role === 'admin';
    const { search, category_id, is_active } = req.query;

    let query = `
      SELECT p.id, p.store_id, p.category_id, c.category_name,
             p.product_name, p.barcode, p.unit,
             ${isOwner ? 'p.cost_price,' : ''}
             p.selling_price, p.stock, p.minimum_stock, p.is_active,
             p.created_at, p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.store_id = ?
    `;
    const params = [storeId];

    // Default: Kasir hanya melihat produk aktif. Owner bisa filter
    if (is_active !== undefined) {
      query += ' AND p.is_active = ?';
      params.push(is_active === 'true' || is_active === '1' ? 1 : 0);
    } else if (!isOwner) {
      query += ' AND p.is_active = 1';
    }

    if (category_id) {
      query += ' AND p.category_id = ?';
      params.push(category_id);
    }

    if (search) {
      query += ' AND (p.product_name LIKE ? OR p.barcode LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY p.product_name ASC';

    const [products] = await pool.query(query, params);
    return successResponse(res, products, 'Daftar produk berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/products/:id
 */
async function getProductById(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const isOwner = req.user.role === 'owner' || req.user.role === 'admin';
    const { id } = req.params;

    const query = `
      SELECT p.id, p.store_id, p.category_id, c.category_name,
             p.product_name, p.barcode, p.unit,
             ${isOwner ? 'p.cost_price,' : ''}
             p.selling_price, p.stock, p.minimum_stock, p.is_active,
             p.created_at, p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.id = ? AND p.store_id = ?
    `;

    const [rows] = await pool.query(query, [id, storeId]);

    if (rows.length === 0) {
      return errorResponse(res, 'Produk tidak ditemukan pada toko ini.', 404);
    }

    return successResponse(res, rows[0], 'Detail produk berhasil diambil.');
  } catch (error) {
    next(error);
  }
}

/**
 * GET /api/v1/products/barcode/:code (Pencarian cepat barcode pemindai)
 */
async function getProductByBarcode(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const isOwner = req.user.role === 'owner' || req.user.role === 'admin';
    const { code } = req.params;

    const query = `
      SELECT p.id, p.store_id, p.category_id, c.category_name,
             p.product_name, p.barcode, p.unit,
             ${isOwner ? 'p.cost_price,' : ''}
             p.selling_price, p.stock, p.minimum_stock, p.is_active,
             p.created_at, p.updated_at
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.barcode = ? AND p.store_id = ? AND p.is_active = 1
    `;

    const [rows] = await pool.query(query, [code, storeId]);

    if (rows.length === 0) {
      return errorResponse(res, `Produk dengan barcode '${code}' tidak ditemukan atau tidak aktif.`, 404);
    }

    return successResponse(res, rows[0], 'Produk berhasil ditemukan melalui barcode.');
  } catch (error) {
    next(error);
  }
}

/**
 * POST /api/v1/products (Owner only)
 */
async function createProduct(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const {
      category_id = null,
      product_name,
      barcode = null,
      unit = 'Pcs',
      cost_price = 0,
      selling_price,
      stock = 0,
      minimum_stock = 5,
    } = req.body;

    if (!product_name) {
      return errorResponse(res, 'Nama produk wajib diisi.', 422);
    }

    if (selling_price === undefined || selling_price === null) {
      return errorResponse(res, 'Harga jual wajib diisi.', 422);
    }

    // Periksa keunikan barcode di toko yang sama jika barcode diisi
    if (barcode) {
      const [existingBarcode] = await pool.query(
        'SELECT id FROM products WHERE barcode = ? AND store_id = ? AND is_active = 1',
        [barcode, storeId]
      );
      if (existingBarcode.length > 0) {
        return errorResponse(res, 'Barcode sudah terdaftar pada produk aktif lain di toko ini.', 409);
      }
    }

    const [result] = await pool.query(
      `INSERT INTO products 
       (store_id, category_id, product_name, barcode, unit, cost_price, selling_price, stock, minimum_stock, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, NOW(), NOW())`,
      [storeId, category_id || null, product_name, barcode || null, unit, cost_price, selling_price, stock, minimum_stock]
    );

    const newProductId = result.insertId;

    // Jika ada stok awal, catat ke stock_movements
    if (stock > 0) {
      await pool.query(
        `INSERT INTO stock_movements (store_id, product_id, user_id, movement_type, quantity, stock_before, stock_after, reference_type, notes, created_at)
         VALUES (?, ?, ?, 'in', ?, 0, ?, 'initial_stock', 'Stok awal produk baru', NOW())`,
        [storeId, newProductId, req.user.userId, stock, stock]
      );
    }

    const [newProduct] = await pool.query('SELECT * FROM products WHERE id = ?', [newProductId]);
    return successResponse(res, newProduct[0], 'Produk berhasil ditambahkan.', 201);
  } catch (error) {
    next(error);
  }
}

/**
 * PUT /api/v1/products/:id (Owner only)
 */
async function updateProduct(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;
    const {
      category_id,
      product_name,
      barcode,
      unit,
      cost_price,
      selling_price,
      minimum_stock,
      is_active,
    } = req.body;

    const [existing] = await pool.query('SELECT id FROM products WHERE id = ? AND store_id = ?', [id, storeId]);
    if (existing.length === 0) {
      return errorResponse(res, 'Produk tidak ditemukan pada toko ini.', 404);
    }

    // Periksa keunikan barcode jika diubah
    if (barcode) {
      const [existingBarcode] = await pool.query(
        'SELECT id FROM products WHERE barcode = ? AND store_id = ? AND id != ? AND is_active = 1',
        [barcode, storeId, id]
      );
      if (existingBarcode.length > 0) {
        return errorResponse(res, 'Barcode sudah terdaftar pada produk aktif lain di toko ini.', 409);
      }
    }

    await pool.query(
      `UPDATE products 
       SET category_id = COALESCE(?, category_id),
           product_name = COALESCE(?, product_name),
           barcode = COALESCE(?, barcode),
           unit = COALESCE(?, unit),
           cost_price = COALESCE(?, cost_price),
           selling_price = COALESCE(?, selling_price),
           minimum_stock = COALESCE(?, minimum_stock),
           is_active = COALESCE(?, is_active),
           updated_at = NOW()
       WHERE id = ? AND store_id = ?`,
      [
        category_id !== undefined ? category_id : null,
        product_name || null,
        barcode !== undefined ? barcode : null,
        unit || null,
        cost_price !== undefined ? cost_price : null,
        selling_price !== undefined ? selling_price : null,
        minimum_stock !== undefined ? minimum_stock : null,
        is_active !== undefined ? (is_active ? 1 : 0) : null,
        id,
        storeId,
      ]
    );

    const [updatedProduct] = await pool.query('SELECT * FROM products WHERE id = ?', [id]);
    return successResponse(res, updatedProduct[0], 'Data produk berhasil diperbarui.');
  } catch (error) {
    next(error);
  }
}

/**
 * DELETE /api/v1/products/:id (Owner only - Soft Delete)
 */
async function deleteProduct(req, res, next) {
  try {
    const storeId = req.user.storeId;
    const { id } = req.params;

    // Periksa apakah produk ada
    const [existing] = await pool.query(
      'SELECT id, product_name FROM products WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    if (existing.length === 0) {
      return errorResponse(res, 'Produk tidak ditemukan pada toko ini.', 404);
    }

    // Soft delete menggunakan is_active = 0
    await pool.query(
      'UPDATE products SET is_active = 0, updated_at = NOW() WHERE id = ? AND store_id = ?',
      [id, storeId]
    );

    return successResponse(res, null, `Produk '${existing[0].product_name}' berhasil dinonaktifkan.`);
  } catch (error) {
    next(error);
  }
}

module.exports = {
  getProducts,
  getProductById,
  getProductByBarcode,
  createProduct,
  updateProduct,
  deleteProduct,
};
