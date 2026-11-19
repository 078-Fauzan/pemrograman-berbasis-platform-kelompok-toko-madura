-- ============================================================
-- DATABASE DDL: umkmate_db
-- Aplikasi Manajemen Bisnis Warung Madura dan Toko Kelontong
-- ============================================================

CREATE DATABASE IF NOT EXISTS `umkmate_db` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `umkmate_db`;

-- Matikan foreign key check sementara saat inisialisasi tabel
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `activity_logs`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `expenses`;
DROP TABLE IF EXISTS `expense_categories`;
DROP TABLE IF EXISTS `stock_movements`;
DROP TABLE IF EXISTS `payments`;
DROP TABLE IF EXISTS `sale_items`;
DROP TABLE IF EXISTS `sales`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `purchase_items`;
DROP TABLE IF EXISTS `purchases`;
DROP TABLE IF EXISTS `suppliers`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `stores`;

SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------
-- 1. TABEL STORES (Informasi Toko)
-- ------------------------------------------------------------
CREATE TABLE `stores` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_name` VARCHAR(150) NOT NULL,
    `owner_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `phone` VARCHAR(25) NOT NULL,
    `address` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_stores_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. TABEL USERS (Pengguna: Admin/Owner, Kasir, dan Pengunjung/Customer)
-- ------------------------------------------------------------
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(25) NULL,
    `address` TEXT NULL,
    `role` ENUM('admin', 'owner', 'cashier', 'customer') NOT NULL DEFAULT 'customer',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_users_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_users_store_role` (`store_id`, `role`),
    INDEX `idx_users_email` (`email`),
    INDEX `idx_users_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. TABEL CATEGORIES (Kategori Produk)
-- ------------------------------------------------------------
CREATE TABLE `categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `category_name` VARCHAR(100) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_categories_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_categories_store` (`store_id`, `category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. TABEL PRODUCTS (Master Produk & Inventaris)
-- ------------------------------------------------------------
CREATE TABLE `products` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `category_id` INT NULL,
    `product_name` VARCHAR(200) NOT NULL,
    `barcode` VARCHAR(100) NULL,
    `unit` VARCHAR(30) NOT NULL DEFAULT 'Pcs',
    `cost_price` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `selling_price` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `stock` INT NOT NULL DEFAULT 0,
    `minimum_stock` INT NOT NULL DEFAULT 5,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_products_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) 
        REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX `idx_products_store_barcode` (`store_id`, `barcode`),
    INDEX `idx_products_store_active` (`store_id`, `is_active`),
    INDEX `idx_products_store_stock` (`store_id`, `stock`),
    INDEX `idx_products_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. TABEL SUPPLIERS (Pemasok / Agen Grosir)
-- ------------------------------------------------------------
CREATE TABLE `suppliers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `supplier_name` VARCHAR(150) NOT NULL,
    `phone` VARCHAR(25) NULL,
    `address` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_suppliers_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_suppliers_store` (`store_id`, `supplier_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 6. TABEL PURCHASES (Faktur Pembelian Stok Grosir)
-- ------------------------------------------------------------
CREATE TABLE `purchases` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `supplier_id` INT NULL,
    `created_by` INT NOT NULL,
    `invoice_number` VARCHAR(50) NOT NULL UNIQUE,
    `total` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `purchase_date` DATE NOT NULL,
    `notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_purchases_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_purchases_supplier` FOREIGN KEY (`supplier_id`) 
        REFERENCES `suppliers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_purchases_user` FOREIGN KEY (`created_by`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_purchases_store_date` (`store_id`, `purchase_date`),
    INDEX `idx_purchases_invoice` (`invoice_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 7. TABEL PURCHASE_ITEMS (Rincian Item Pembelian)
-- ------------------------------------------------------------
CREATE TABLE `purchase_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `purchase_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `cost_price` DECIMAL(15, 2) NOT NULL,
    `subtotal` DECIMAL(15, 2) NOT NULL,
    CONSTRAINT `fk_purchase_items_purchase` FOREIGN KEY (`purchase_id`) 
        REFERENCES `purchases` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_purchase_items_product` FOREIGN KEY (`product_id`) 
        REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_purchase_items_purchase` (`purchase_id`),
    INDEX `idx_purchase_items_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 8. TABEL CUSTOMERS (Data Pelanggan Toko)
-- ------------------------------------------------------------
CREATE TABLE `customers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `customer_name` VARCHAR(150) NOT NULL,
    `phone` VARCHAR(25) NULL,
    `address` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_customers_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_customers_store_name` (`store_id`, `customer_name`),
    INDEX `idx_customers_phone` (`store_id`, `phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 9. TABEL SALES (Transaksi Penjualan Kasir / POS)
-- ------------------------------------------------------------
CREATE TABLE `sales` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `customer_id` INT NULL,
    `cashier_id` INT NOT NULL,
    `invoice_number` VARCHAR(50) NOT NULL UNIQUE,
    `subtotal` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `discount` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `total` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `status` ENUM('completed', 'voided') NOT NULL DEFAULT 'completed',
    `sale_date` DATE NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_sales_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_sales_customer` FOREIGN KEY (`customer_id`) 
        REFERENCES `customers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_sales_cashier` FOREIGN KEY (`cashier_id`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_sales_store_date` (`store_id`, `sale_date`),
    INDEX `idx_sales_store_status` (`store_id`, `status`),
    INDEX `idx_sales_cashier` (`cashier_id`),
    INDEX `idx_sales_invoice` (`invoice_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 10. TABEL SALE_ITEMS (Rincian Item Penjualan dengan Snapshot HPP)
-- ------------------------------------------------------------
CREATE TABLE `sale_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sale_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `quantity` INT NOT NULL,
    `selling_price` DECIMAL(15, 2) NOT NULL,
    `unit_cost` DECIMAL(15, 2) NOT NULL COMMENT 'Snapshot harga modal saat transaksi berlangsung',
    `subtotal` DECIMAL(15, 2) NOT NULL,
    CONSTRAINT `fk_sale_items_sale` FOREIGN KEY (`sale_id`) 
        REFERENCES `sales` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_sale_items_product` FOREIGN KEY (`product_id`) 
        REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_sale_items_sale` (`sale_id`),
    INDEX `idx_sale_items_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 11. TABEL PAYMENTS (Catatan Pembayaran Faktur Penjualan)
-- ------------------------------------------------------------
CREATE TABLE `payments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `sale_id` INT NOT NULL UNIQUE,
    `received_by` INT NOT NULL,
    `payment_method` ENUM('cash', 'transfer', 'qris') NOT NULL DEFAULT 'cash',
    `amount` DECIMAL(15, 2) NOT NULL,
    `cash_received` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `change_amount` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_payments_sale` FOREIGN KEY (`sale_id`) 
        REFERENCES `sales` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_payments_user` FOREIGN KEY (`received_by`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_payments_sale` (`sale_id`),
    INDEX `idx_payments_method` (`payment_method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 12. TABEL STOCK_MOVEMENTS (Audit Log Mutasi Fisik Stok)
-- ------------------------------------------------------------
CREATE TABLE `stock_movements` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `movement_type` ENUM('sale', 'purchase', 'in', 'out', 'adjustment', 'void') NOT NULL,
    `quantity` INT NOT NULL,
    `stock_before` INT NOT NULL,
    `stock_after` INT NOT NULL,
    `reference_type` VARCHAR(50) NULL COMMENT 'sale, purchase, manual, void',
    `reference_id` INT NULL,
    `notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_stock_movements_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_stock_movements_product` FOREIGN KEY (`product_id`) 
        REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT `fk_stock_movements_user` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_stock_movements_store_product` (`store_id`, `product_id`),
    INDEX `idx_stock_movements_created` (`store_id`, `created_at`),
    INDEX `idx_stock_movements_type` (`movement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 13. TABEL EXPENSE_CATEGORIES (Kategori Beban Pengeluaran)
-- ------------------------------------------------------------
CREATE TABLE `expense_categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `category_name` VARCHAR(100) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_expense_categories_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_expense_categories_store` (`store_id`, `category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 14. TABEL EXPENSES (Pencatatan Beban Pengeluaran Operasional)
-- ------------------------------------------------------------
CREATE TABLE `expenses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `category_id` INT NULL,
    `user_id` INT NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `amount` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `expense_date` DATE NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_expenses_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_expenses_category` FOREIGN KEY (`category_id`) 
        REFERENCES `expense_categories` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT `fk_expenses_user` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_expenses_store_date` (`store_id`, `expense_date`),
    INDEX `idx_expenses_category` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 15. TABEL NOTIFICATIONS (Pemberitahuan Sistem & Stok Menipis)
-- ------------------------------------------------------------
CREATE TABLE `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `user_id` INT NULL,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `type` ENUM('stock_alert', 'system', 'transaction', 'order', 'order_status') NOT NULL DEFAULT 'system',
    `is_read` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_notifications_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_notifications_store_read` (`store_id`, `is_read`),
    INDEX `idx_notifications_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 16. TABEL ACTIVITY_LOGS (Audit Jejak Rekam Pengguna)
-- ------------------------------------------------------------
CREATE TABLE `activity_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    `activity` VARCHAR(100) NOT NULL,
    `description` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_activity_logs_store` FOREIGN KEY (`store_id`) 
        REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_activity_logs_user` FOREIGN KEY (`user_id`) 
        REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_activity_logs_store` (`store_id`, `created_at`),
    INDEX `idx_activity_logs_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 17. TABEL ORDERS (Pesanan Mandiri Pengunjung / Pembeli)
-- ------------------------------------------------------------
CREATE TABLE `orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `store_id` INT NOT NULL DEFAULT 1,
    `user_id` INT NOT NULL,
    `order_number` VARCHAR(50) NOT NULL UNIQUE,
    `customer_name` VARCHAR(150) NOT NULL,
    `customer_phone` VARCHAR(25) NOT NULL,
    `total_amount` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `order_type` ENUM('takeaway', 'delivery') NOT NULL DEFAULT 'takeaway',
    `delivery_address` TEXT NULL,
    `payment_method` ENUM('cash', 'qris', 'transfer') NOT NULL DEFAULT 'cash',
    `status` ENUM('pending', 'confirmed', 'processing', 'ready', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    `notes` TEXT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_orders_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_orders_store_status` (`store_id`, `status`),
    INDEX `idx_orders_user` (`user_id`),
    INDEX `idx_orders_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 18. TABEL ORDER_ITEMS (Rincian Produk Pesanan Pembeli)
-- ------------------------------------------------------------
CREATE TABLE `order_items` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    `product_name` VARCHAR(200) NOT NULL,
    `quantity` INT NOT NULL DEFAULT 1,
    `price` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    `subtotal` DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX `idx_order_items_order` (`order_id`),
    INDEX `idx_order_items_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
