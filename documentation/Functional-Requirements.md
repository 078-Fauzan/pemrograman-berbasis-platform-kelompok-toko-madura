# ANALISIS KEBUTUHAN SISTEM (FUNCTIONAL & NON-FUNCTIONAL REQUIREMENTS)
## APLIKASI UMKMATE

**Nama Aplikasi:** UMKMate  
**Kategori:** Sistem Informasi Manajemen Warung Madura dan Toko Kelontong  
**Platform:** Android (Flutter)  
**Backend:** Node.js + Express.js  
**Database:** MySQL  

---

## 1. Analisis Kebutuhan Fungsional (30 Fitur)

### A. Autentikasi dan Pengguna
1. **Registrasi Toko & Owner (FR-01):**
   - Pendaftaran akun baru bagi pemilik warung/toko.
   - Input: Nama Toko, Nama Pemilik, Email, Nomor Telepon, Password.
   - Output: Akun Owner terdaftar, Store ID unik terbuat otomatis, toko langsung siap digunakan.
2. **Login Multi-Role (FR-02):**
   - Otentikasi menggunakan Email dan Password.
   - Backend mengenali role (`owner` atau `cashier`).
   - Token JWT dikembalikan berisi `userId`, `storeId`, dan `role`.
   - Frontend mengarahkan pengguna secara otomatis ke halaman yang sesuai hak aksesnya.
3. **Lupa & Reset Password (FR-03):**
   - Mekanisme reset password berbasis kode token verifikasi/temporary reset token yang aman.
   - Password lama tidak pernah dikirim balik dalam bentuk teks biasa.
4. **Manajemen Profil Pengguna & Toko (FR-04):**
   - Pengguna dapat memperbarui nama, nomor telepon, dan email.
   - Owner memiliki wewenang memperbarui informasi toko: Nama Toko, Alamat, Nomor Telepon Toko, Catatan Struk.
5. **Manajemen Akun Kasir (FR-05):**
   - Owner dapat membuat akun kasir baru untuk tokonya.
   - Owner dapat mengaktifkan atau menonaktifkan kasir (`is_active: 0/1`).
   - Kasir non-aktif langsung ditolak saat login.

### B. Dashboard dan Analitik
6. **Dashboard Ringkasan Bisnis (FR-06):**
   - Menampilkan metrik real-time: Total Penjualan Hari Ini, Jumlah Transaksi Hari Ini, Total Produk Aktif, Jumlah Item Stok Menipis.
7. **Grafik Penjualan Interaktif (FR-07):**
   - Visualisasi tren penjualan harian (7 hari terakhir), mingguan, dan bulanan menggunakan `fl_chart`.
8. **Statistik Transaksi (FR-08):**
   - Metrik rata-rata nilai transaksi (Average Order Value / AOV), total transaksi sukses, perbandingan metode pembayaran.
9. **Produk Terlaris (Top Selling) (FR-09):**
   - Menampilkan peringkat produk dengan kuantitas terjual terbanyak dalam periode waktu tertentu.
10. **Peringatan Stok Menipis (FR-10):**
    - Sistem otomatis mendeteksi produk dengan `stock <= minimum_stock`.
    - Menampilkan daftar produk darurat yang perlu restock / order ke pemasok.

### C. Manajemen Produk dan Inventaris
11. **Tambah Produk (FR-11):**
    - Input: Nama Produk, Barcode, Kategori, Satuan (Pcs, Renceng, Dus, Kg, Liter), Harga Modal (Cost Price), Harga Jual (Selling Price), Stok Awal, Stok Minimum.
    - Validasi keunikan barcode dalam satu toko (`store_id` + `barcode`).
12. **Edit Produk (FR-12):**
    - Pembaruan rincian data produk dan harga.
13. **Soft Delete / Nonaktifkan Produk (FR-13):**
    - Menggunakan flag `is_active = false`.
    - Mencegah error foreign key pada transaksi historis, produk tidak muncul lagi di katalog kasir namun riwayat penjualan masa lalu tetap valid.
14. **Kategori Produk (FR-14):**
    - Tambah, ubah, dan hapus kategori produk per toko.
15. **Manajemen & Monitoring Stok (FR-15):**
    - Katalog inventaris lengkap dengan pencarian real-time dan filter kategori serta kondisi stok (Normal, Rendah, Habis).
16. **Pencatatan Stok Masuk (FR-16):**
    - Penambahan stok manual non-pembelian (misal: bonus supplier, penyesuaian opname).
    - Menghitung stok baru dan mencatat ke log mutasi stok.
17. **Pencatatan Stok Keluar (FR-17):**
    - Pengurangan stok non-penjualan (misal: barang rusak, kadaluarsa, hilang, atau dikonsumsi sendiri).
    - Wajib menyertakan alasan/keterangan yang tercatat di `stock_movements`.
18. **Scan Barcode Produk (FR-18):**
    - Pemanfaatan kamera perangkat melalui `mobile_scanner`.
    - Membaca barcode EAN-13, UPC, Code 128, QR Code, dan langsung mencocokkan ke database produk toko.

### D. Penjualan dan Kasir (Point of Sale / POS)
19. **Keranjang Belanja Pintar (FR-19):**
    - Tambah produk via sentuh katalog atau scan barcode.
    - Ubah jumlah item, tombol cepat (+1, -1), hapus item, kalkulasi otomatis subtotal per item.
20. **Checkout Transaksi (FR-20):**
    - Ringkasan belanja, opsi penautan ke pelanggan terdaftar (opsional/anonim).
    - Penguncian stok dan validasi ketersediaan saat checkout.
21. **Kalkulasi Transaksi Otomatis (FR-21):**
    - Perhitungan Subtotal, Diskon (nominal/persen), Total Bayar, Uang Diterima, dan Uang Kembalian secara presisi (rupiah).
22. **Pilihan Metode Pembayaran (FR-22):**
    - Tunai (Cash): dengan penghitungan kembalian dan saran uang pas.
    - Transfer Bank: pencatatan transaksi non-tunai.
    - QRIS: pencatatan pembayaran QRIS statis warung.
23. **Struk Digital & Bukti Belanja (FR-23):**
    - Pembuatan struk format rapi: No Invoice, Nama Toko, Tanggal, Kasir, Rincian Barang, Total, Pembayaran, Kembalian.
    - Dapat dibagikan via WhatsApp/aplikasi pihak ketiga (`share_plus`) atau dicetak ke thermal printer.
24. **Riwayat & Filter Transaksi (FR-24):**
    - Owner dapat memantau seluruh transaksi toko.
    - Kasir hanya dapat melihat riwayat transaksi miliknya sendiri pada shift aktif.
    - Fitur filter berdasarkan rentang tanggal, status (`completed`, `voided`), dan pencarian nomor invoice.

### E. Pelanggan dan Pemasok
25. **Manajemen Pelanggan (FR-25):**
    - Pendataan nama pelanggan setia, nomor telepon, dan alamat.
26. **Manajemen Pemasok (FR-26):**
    - Pendataan nama supplier (misal: distributor sembako, agen rokok, grosir minuman), nomor telepon, dan alamat.
27. **Riwayat Pembelian Pelanggan (FR-27):**
    - Melihat akumulasi total transaksi dan rincian transaksi belanja yang dilakukan pelanggan tertentu.

### F. Keuangan dan Laporan
28. **Pencatatan Biaya Operasional / Pengeluaran (FR-28):**
    - Pencatatan biaya seperti listrik warung, sewa tempat, bensin belanja grosir, kantong plastik, dll.
    - Dikelompokkan berdasarkan kategori pengeluaran (`expense_categories`).
29. **Laporan Laba Kotor (Gross Profit) (FR-29):**
    - Formula: Total Penjualan Bersih - Harga Pokok Penjualan (HPP / COGS).
    - HPP dihitung dari snapshot `unit_cost` pada saat transaksi berlangsung.
30. **Laporan Keuangan & Ringkasan Performa Toko (FR-30):**
    - Ringkasan: Total Omset (Sales), Total HPP, Laba Kotor (Gross Profit), Total Pengeluaran Operasional (Expenses), dan Laba Bersih Operasional (Net Operating Profit).
    - Filter periode: Harian, Mingguan, Bulanan, dan Custom Date Range.

---

## 2. Kebutuhan Non-Fungsional (NFR)

1. **Keamanan (Security):**
   - Hashing password menggunakan algoritma `bcrypt` dengan salt rounds minimum 10.
   - Otentikasi berbasis Stateless JSON Web Token (JWT) dengan masa kedaluwarsa teratur.
   - Proteksi SQL Injection melalui parameterized queries (`mysql2/promise`).
   - Multi-tenant Data Isolation: Setiap query wajib menyertakan filter `store_id` yang diekstrak langsung dari payload token JWT terverifikasi, bukan dari input body/query client.
2. **Integritas Transaksi (Data Integrity & Concurrency):**
   - Penjualan, pembelian, dan restock wajib menggunakan **Database Transaction (ACID)** (`START TRANSACTION`, `COMMIT`, `ROLLBACK`).
   - Penerapan `SELECT ... FOR UPDATE` pada saat pengecekan stok kasir untuk mencegah race condition / stok negatif ketika terjadi checkout bersamaan.
   - Snapshot nilai modal: `sale_items.unit_cost` disimpan permanen saat transaksi dibuat agar laporan laba kotor historis tidak bergeser jika harga modal barang diperbarui di kemudian hari.
3. **Format & Lokalisasi:**
   - Mata Uang: Rupiah (`IDR` / `Rp xx.xxx`).
   - Format Tanggal: `DD-MM-YYYY` / `DD MMMM YYYY, HH:mm WIB`.
   - Zona Waktu: `Asia/Jakarta` (WIB, UTC+7).
   - Tipe Data Keuangan di MySQL: `DECIMAL(15, 2)` (menghindari floating-point precision error).
4. **Performa & Ketersediaan:**
   - Response time API rata-rata < 200ms pada jaringan lokal LAN/Wi-Fi.
   - Penggunaan index komposit pada foreign key dan kolom filter (`store_id`, `created_at`, `barcode`, `invoice_number`).
5. **Usability & UX:**
   - Tampilan bersih, kontras tinggi, mudah dioperasikan di bawah pencahayaan warung.
   - Navigasi responsif dengan tombol sentuh yang bersahabat untuk layar sentuh ponsel Android kasir.
