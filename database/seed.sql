-- ============================================================
-- SEED DATA: umkmate_db
-- Data Awal Demo untuk Pengujian Warung Madura dan Toko Kelontong
-- Password semua akun demo: Password123!
-- ============================================================

USE `umkmate_db`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. STORES
INSERT INTO `stores` (`id`, `store_name`, `owner_name`, `email`, `phone`, `address`, `created_at`, `updated_at`)
VALUES
(1, 'Warung Madura Berkah', 'Fauzan', 'owner@umkmate.com', '081234567890', 'Jl. Kaliurang KM 5.5 No. 12, Sleman, D.I. Yogyakarta', NOW(), NOW());

-- 2. USERS (Password: Password123!)
-- Hash: $2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe
INSERT INTO `users` (`id`, `store_id`, `name`, `email`, `password`, `phone`, `role`, `is_active`, `created_at`, `updated_at`)
VALUES
(1, 1, 'Fauzan (Owner)', 'owner@umkmate.com', '$2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe', '081234567890', 'owner', 1, NOW(), NOW()),
(2, 1, 'Ahmad Subarjo (Kasir Pagi)', 'kasir1@umkmate.com', '$2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe', '081298765432', 'cashier', 1, NOW(), NOW()),
(3, 1, 'Siti Aminah (Kasir Sore)', 'kasir2@umkmate.com', '$2a$10$ffNLNI1S6SmOjEeiIssoCulXyKemx5sfwaF7/kE/bBNAYFYjDLpOe', '081287654321', 'cashier', 1, NOW(), NOW());

-- 3. CATEGORIES
INSERT INTO `categories` (`id`, `store_id`, `category_name`, `created_at`)
VALUES
(1, 1, 'Sembako', NOW()),
(2, 1, 'Minuman', NOW()),
(3, 1, 'Makanan Ringan', NOW()),
(4, 1, 'Sabun & Kebersihan', NOW()),
(5, 1, 'Rokok & Tembakau', NOW()),
(6, 1, 'Obat & P3K', NOW());

-- 4. PRODUCTS (32 Produk Relevan Warung Madura)
INSERT INTO `products` (`id`, `store_id`, `category_id`, `product_name`, `barcode`, `unit`, `cost_price`, `selling_price`, `stock`, `minimum_stock`, `is_active`, `created_at`, `updated_at`)
VALUES
-- Kategori Sembako
(1, 1, 1, 'Beras Ramos Super 5 Kg', '8991001100012', 'Karung', 64000.00, 72000.00, 25, 5, 1, NOW(), NOW()),
(2, 1, 1, 'Minyak Goreng Bimoli 1 Liter', '8991001100029', 'Pouch', 16500.00, 19000.00, 40, 10, 1, NOW(), NOW()),
(3, 1, 1, 'Minyak Goreng Filma 2 Liter', '8991001100036', 'Pouch', 34000.00, 38500.00, 18, 5, 1, NOW(), NOW()),
(4, 1, 1, 'Gula Pasir Gulaku Kuning 1 Kg', '8991001100043', 'Bungkus', 15000.00, 17500.00, 30, 8, 1, NOW(), NOW()),
(5, 1, 1, 'Telur Ayam Negeri 1 Kg', '8991001100050', 'Kg', 26000.00, 29000.00, 50, 10, 1, NOW(), NOW()),
(6, 1, 1, 'Tepung Terigu Segitiga Biru 1 Kg', '8991001100067', 'Bungkus', 11000.00, 13000.00, 20, 5, 1, NOW(), NOW()),

-- Kategori Minuman
(7, 1, 2, 'Air Mineral Le Minerale 600 ml', '8996001414018', 'Botol', 2800.00, 4000.00, 72, 24, 1, NOW(), NOW()),
(8, 1, 2, 'Air Mineral Aqua 600 ml', '8992753211110', 'Botol', 3200.00, 4500.00, 60, 24, 1, NOW(), NOW()),
(9, 1, 2, 'Teh Pucuk Harum 350 ml', '8996001410010', 'Botol', 3100.00, 4500.00, 48, 12, 1, NOW(), NOW()),
(10, 1, 2, 'Kopi Kapal Api Spesial Mix 1 Renceng (10 Sachet)', '8991002100101', 'Renceng', 12000.00, 15000.00, 25, 5, 1, NOW(), NOW()),
(11, 1, 2, 'Kopi Good Day Cappuccino 1 Renceng (10 Sachet)', '8991002100200', 'Renceng', 18000.00, 22000.00, 20, 5, 1, NOW(), NOW()),
(12, 1, 2, 'Susu Kental Manis Frisian Flag Cokelat 370 gr', '8992752011018', 'Kaleng', 11500.00, 13500.00, 15, 5, 1, NOW(), NOW()),
(13, 1, 2, 'Floridina Orange 350 ml', '8998866200238', 'Botol', 2800.00, 4000.00, 36, 12, 1, NOW(), NOW()),
(14, 1, 2, 'Ultra Milk UHT Cokelat 250 ml', '8992741911015', 'Kotak', 5500.00, 7000.00, 24, 6, 1, NOW(), NOW()),

-- Kategori Makanan Ringan & Mi Instan
(15, 1, 3, 'Indomie Goreng Original 85 gr', '089686010145', 'Bungkus', 2900.00, 3500.00, 120, 40, 1, NOW(), NOW()),
(16, 1, 3, 'Indomie Kuah Ayam Bawang 69 gr', '089686010220', 'Bungkus', 2800.00, 3500.00, 80, 40, 1, NOW(), NOW()),
(17, 1, 3, 'Indomie Kuah Soto Mie 70 gr', '089686010312', 'Bungkus', 2800.00, 3500.00, 90, 40, 1, NOW(), NOW()),
(18, 1, 3, 'Mie Sedaap Goreng 90 gr', '8998866200115', 'Bungkus', 2850.00, 3500.00, 60, 30, 1, NOW(), NOW()),
(19, 1, 3, 'Chitato Sapi Panggang 68 gr', '8996001303107', 'Bungkus', 9500.00, 12000.00, 16, 5, 1, NOW(), NOW()),
(20, 1, 3, 'Oreo Vanilla 133 gr', '8992760136017', 'Bungkus', 8500.00, 11000.00, 20, 5, 1, NOW(), NOW()),
(21, 1, 3, 'Beng-Beng Cokelat Wafer 1 Kotak (20 pcs)', '8996001301110', 'Kotak', 36000.00, 44000.00, 10, 3, 1, NOW(), NOW()),

-- Kategori Sabun & Kebersihan
(22, 1, 4, 'Sabun Mandi Lifebuoy Total 10 Batang 110 gr', '8999999011114', 'Batang', 3500.00, 4500.00, 40, 10, 1, NOW(), NOW()),
(23, 1, 4, 'Sampo Pantene Anti Dandruff 160 ml', '8992752111022', 'Botol', 22000.00, 26000.00, 12, 4, 1, NOW(), NOW()),
(24, 1, 4, 'Pasta Gigi Pepsodent 190 gr', '8999999022226', 'Kotak', 12500.00, 15000.00, 18, 5, 1, NOW(), NOW()),
(25, 1, 4, 'Deterjen Rinso Molto Bubuk 770 gr', '8999999033333', 'Bungkus', 19000.00, 22500.00, 15, 4, 1, NOW(), NOW()),
(26, 1, 4, 'Pencuci Piring Sunlight Jeruk Nipis 650 ml', '8999999044440', 'Pouch', 13000.00, 15500.00, 22, 5, 1, NOW(), NOW()),

-- Kategori Rokok (Data Katalog Demo)
(27, 1, 5, 'Sampoerna A Mild 16 Batang', '8992999111118', 'Bungkus', 33000.00, 36000.00, 30, 10, 1, NOW(), NOW()),
(28, 1, 5, 'Djarum Super 12 Batang', '8992999222221', 'Bungkus', 23500.00, 26000.00, 25, 10, 1, NOW(), NOW()),
(29, 1, 5, 'Gudang Garam Surya 16 Batang', '8992999333334', 'Bungkus', 32500.00, 35500.00, 28, 10, 1, NOW(), NOW()),
(30, 1, 5, 'Esse Change Juicy 20 Batang', '8992999444447', 'Bungkus', 38000.00, 42000.00, 15, 5, 1, NOW(), NOW()),

-- Kategori Obat & P3K
(31, 1, 6, 'Paracetamol Kimia Farma 500 mg 1 Strip (10 Tablet)', '8997001100015', 'Strip', 4000.00, 6000.00, 20, 5, 1, NOW(), NOW()),
(32, 1, 6, 'Minyak Kayu Putih Cap Lang 60 ml', '8998888100010', 'Botol', 21000.00, 25000.00, 14, 4, 1, NOW(), NOW());

-- 5. SUPPLIERS (5 Pemasok Grosir)
INSERT INTO `suppliers` (`id`, `store_id`, `supplier_name`, `phone`, `address`, `created_at`)
VALUES
(1, 1, 'Agen Sembako Makmur Jaya', '081399887766', 'Pasar Kranggan Kios B-14, Yogyakarta', NOW()),
(2, 1, 'Distributor Minuman Tirta Kencana', '081255443322', 'Kawasan Industri Ringroad Utara No. 8, Sleman', NOW()),
(3, 1, 'Agen Rokok Surya Mandiri', '081744332211', 'Jl. Magelang KM 4 No. 20, Yogyakarta', NOW()),
(4, 1, 'Grosir Sabun & Personal Care Berkah', '081877665544', 'Jl. Gejayan No. 45, Sleman', NOW()),
(5, 1, 'CV Pangan Nusantara (Beras & Gula)', '081911223344', 'Jl. Wonosari KM 7, Bantul', NOW());

-- 6. CUSTOMERS (10 Pelanggan Tetap Warung)
INSERT INTO `customers` (`id`, `store_id`, `customer_name`, `phone`, `address`, `created_at`)
VALUES
(1, 1, 'Pak Budi Santoso', '085211223344', 'Kost Pogung Baru Blok F-4', NOW()),
(2, 1, 'Ibu Dewi Sartika', '085222334455', 'Pogung Dalangan No. 12', NOW()),
(3, 1, 'Mas Reza Pratama', '085233445566', 'Gang Pandega Marta No. 8', NOW()),
(4, 1, 'Mbak Rina Wulandari', '085244556677', 'Asrama Mahasiswi Pogung Kidul', NOW()),
(5, 1, 'Pak Joko Widodo (Warga RT 02)', '085255667788', 'Jl. Kaliurang KM 5 No. 34', NOW()),
(6, 1, 'Ibu Sri Wahyuni', '085266778899', 'Pogung Lor No. 56', NOW()),
(7, 1, 'Mas Dani Alamsyah', '085277889900', 'Kos Griya Pogung Asri', NOW()),
(8, 1, 'Mbak Maya Safitri', '085288990011', 'Pogung Raya No. 19', NOW()),
(9, 1, 'Pak Hendra Kurniawan', '085299001122', 'Jl. Pandega Sakti No. 7', NOW()),
(10, 1, 'Mbak Putri Ayu', '085200112233', 'Pogung Baru Blok C-2', NOW());

-- 7. EXPENSE_CATEGORIES
INSERT INTO `expense_categories` (`id`, `store_id`, `category_name`, `created_at`)
VALUES
(1, 1, 'Listrik & Token PLN', NOW()),
(2, 1, 'Sewa Tempat Warung', NOW()),
(3, 1, 'Operasional & Kantong Plastik', NOW()),
(4, 1, 'Transportasi Belanja Grosir', NOW()),
(5, 1, 'Kebersihan & Keamanan Lingkungan', NOW());

-- 8. EXPENSES (Pengeluaran Operasional Sampel)
INSERT INTO `expenses` (`id`, `store_id`, `category_id`, `user_id`, `description`, `amount`, `expense_date`, `created_at`)
VALUES
(1, 1, 1, 1, 'Beli Token Listrik PLN 2200VA', 200000.00, CURDATE(), NOW()),
(2, 1, 3, 1, 'Beli Kantong Plastik Kresek 3 Ukuran', 45000.00, CURDATE(), NOW()),
(3, 1, 4, 1, 'Bensin Motor Belanja ke Pasar Kranggan', 25000.00, CURDATE(), NOW());

-- 9. PURCHASES (Pembelian Stok Grosir Sampel)
INSERT INTO `purchases` (`id`, `store_id`, `supplier_id`, `created_by`, `invoice_number`, `total`, `purchase_date`, `notes`, `created_at`)
VALUES
(1, 1, 1, 1, 'PO-20261028-0001', 320000.00, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Restock beras dan minyak goreng awal pekan', NOW());

INSERT INTO `purchase_items` (`id`, `purchase_id`, `product_id`, `quantity`, `cost_price`, `subtotal`)
VALUES
(1, 1, 1, 4, 64000.00, 256000.00),
(2, 1, 2, 4, 16000.00, 64000.00);

-- 10. SALES (Penjualan Sampel 1: Selesai Tunai)
INSERT INTO `sales` (`id`, `store_id`, `customer_id`, `cashier_id`, `invoice_number`, `subtotal`, `discount`, `total`, `status`, `sale_date`, `created_at`)
VALUES
(1, 1, 1, 2, 'INV-20261031-0001', 25500.00, 0.00, 25500.00, 'completed', CURDATE(), NOW());

INSERT INTO `sale_items` (`id`, `sale_id`, `product_id`, `quantity`, `selling_price`, `unit_cost`, `subtotal`)
VALUES
(1, 1, 15, 3, 3500.00, 2900.00, 10500.00), -- 3x Indomie Goreng
(2, 1, 7, 2, 4000.00, 2800.00, 8000.00),   -- 2x Le Minerale
(3, 1, 14, 1, 7000.00, 5500.00, 7000.00);  -- 1x Ultra Milk

INSERT INTO `payments` (`id`, `sale_id`, `received_by`, `payment_method`, `amount`, `cash_received`, `change_amount`, `created_at`)
VALUES
(1, 1, 2, 'cash', 25500.00, 50000.00, 24500.00, NOW());

-- Mutasi stok untuk transaksi 1
INSERT INTO `stock_movements` (`store_id`, `product_id`, `user_id`, `movement_type`, `quantity`, `stock_before`, `stock_after`, `reference_type`, `reference_id`, `notes`, `created_at`)
VALUES
(1, 15, 2, 'sale', 3, 123, 120, 'sale', 1, 'Penjualan nota INV-20261031-0001', NOW()),
(1, 7, 2, 'sale', 2, 74, 72, 'sale', 1, 'Penjualan nota INV-20261031-0001', NOW()),
(1, 14, 2, 'sale', 1, 25, 24, 'sale', 1, 'Penjualan nota INV-20261031-0001', NOW());

-- Penjualan Sampel 2: Pembayaran QRIS
INSERT INTO `sales` (`id`, `store_id`, `customer_id`, `cashier_id`, `invoice_number`, `subtotal`, `discount`, `total`, `status`, `sale_date`, `created_at`)
VALUES
(2, 1, 3, 3, 'INV-20261031-0002', 48000.00, 0.00, 48000.00, 'completed', CURDATE(), NOW());

INSERT INTO `sale_items` (`id`, `sale_id`, `product_id`, `quantity`, `selling_price`, `unit_cost`, `subtotal`)
VALUES
(4, 2, 27, 1, 36000.00, 33000.00, 36000.00), -- 1x Sampoerna Mild
(5, 2, 19, 1, 12000.00, 9500.00, 12000.00);  -- 1x Chitato

INSERT INTO `payments` (`id`, `sale_id`, `received_by`, `payment_method`, `amount`, `cash_received`, `change_amount`, `created_at`)
VALUES
(2, 2, 3, 'qris', 48000.00, 48000.00, 0.00, NOW());

INSERT INTO `stock_movements` (`store_id`, `product_id`, `user_id`, `movement_type`, `quantity`, `stock_before`, `stock_after`, `reference_type`, `reference_id`, `notes`, `created_at`)
VALUES
(1, 27, 3, 'sale', 1, 31, 30, 'sale', 2, 'Penjualan nota INV-20261031-0002', NOW()),
(1, 19, 3, 'sale', 1, 17, 16, 'sale', 2, 'Penjualan nota INV-20261031-0002', NOW());

-- 11. NOTIFICATIONS (Notifikasi Sampel)
INSERT INTO `notifications` (`id`, `store_id`, `user_id`, `title`, `message`, `type`, `is_read`, `created_at`)
VALUES
(1, 1, 1, 'Selamat Datang di UMKMate', 'Sistem POS dan manajemen Warung Madura Berkah berhasil diaktifkan.', 'system', 0, NOW()),
(2, 1, 1, 'Peringatan Stok', 'Produk Beng-Beng Cokelat Wafer tersisa 10 Kotak, mendekati batas minimum.', 'stock_alert', 0, NOW());

-- 12. ACTIVITY_LOGS (Log Sampel)
INSERT INTO `activity_logs` (`id`, `store_id`, `user_id`, `activity`, `description`, `created_at`)
VALUES
(1, 1, 1, 'SYSTEM_INIT', 'Inisialisasi data toko dan master produk Warung Madura Berkah', NOW()),
(2, 1, 2, 'LOGIN', 'Kasir Ahmad Subarjo berhasil login sistem shift pagi', NOW()),
(3, 1, 2, 'CREATE_SALE', 'Penjualan kasir faktur INV-20261031-0001 senilai Rp 25.500', NOW());

SET FOREIGN_KEY_CHECKS = 1;
