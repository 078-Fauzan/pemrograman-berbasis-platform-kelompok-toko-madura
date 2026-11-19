# SPESIFIKASI REST API UMKMATE

**Base URL:** `http://<IP_LAN_KOMPUTER>:5000/api/v1`  
**Content-Type:** `application/json`  
**Header Autentikasi:** `Authorization: Bearer <JWT_TOKEN>`  

---

## 1. Format Respons Standar

### Respons Sukses:
```json
{
  "success": true,
  "message": "Data berhasil diambil",
  "data": { ... }
}
```

### Respons Gagal / Error:
```json
{
  "success": false,
  "message": "Pesan deskripsi kesalahan",
  "errors": [ ... ]
}
```

---

## 2. Rincian Endpoint REST API

### A. Authentication & User Profile
- `POST /auth/register` : Mendaftarkan toko baru dan akun owner.
- `POST /auth/login` : Login user (mengembalikan token JWT, role, & store info).
- `POST /auth/forgot-password` : Mengajukan reset password.
- `POST /auth/reset-password` : Mereset password dengan token reset valid.
- `GET /auth/me` : Mengambil informasi profil pengguna yang sedang login.
- `PUT /auth/profile` : Memperbarui nama, telepon, dan profil toko (khusus owner).

### B. Users Management (Role Owner)
- `GET /users` : Mengambil daftar seluruh staf kasir toko.
- `POST /users` : Membuat akun kasir baru.
- `GET /users/:id` : Mengambil detail akun staf.
- `PUT /users/:id` : Mengedit profil kasir.
- `PATCH /users/:id/status` : Mengaktifkan/menonaktifkan akun kasir (`is_active: 0/1`).

### C. Dashboard & Analytics (Role Owner)
- `GET /dashboard` : Ringkasan metrik hari ini (omset, transaksi, produk aktif, stok menipis).
- `GET /dashboard/sales-chart` : Data time-series penjualan untuk visualisasi `fl_chart`.
- `GET /dashboard/transaction-stats` : Rata-rata nilai belanja dan statistik metode bayar.
- `GET /dashboard/best-selling` : Top produk dengan volume penjualan tertinggi.

### D. Notifications
- `GET /notifications` : Mengambil daftar peringatan (terutama stok menipis).
- `PATCH /notifications/:id/read` : Menandai notifikasi telah dibaca.

### E. Products & Categories
- `GET /categories` : Mengambil seluruh kategori produk toko.
- `POST /categories` : Menambah kategori baru (Owner).
- `PUT /categories/:id` : Mengubah kategori (Owner).
- `DELETE /categories/:id` : Menghapus kategori kosong (Owner).
- `GET /products` : Mengambil katalog produk (mendukung search & filter kategori).
- `POST /products` : Menambah produk baru (Owner).
- `GET /products/:id` : Mengambil detail produk.
- `PUT /products/:id` : Memperbarui data produk (Owner).
- `DELETE /products/:id` : Soft delete produk (`is_active = 0`) (Owner).
- `GET /products/barcode/:code` : Mencari produk spesifik berdasarkan barcode kamera.

### F. Inventory & Stock Movements
- `GET /stock` : Katalog status stok seluruh barang (Normal / Menipis / Habis).
- `POST /stock/in` : Pencatatan stok masuk manual / opname (Owner).
- `POST /stock/out` : Pencatatan stok keluar (rusak/kadaluarsa/konsumsi) (Owner).
- `GET /stock/movements` : Riwayat pergerakan mutasi stok barang (`stock_movements`).

### G. Suppliers & Purchases (Restock Grosir)
- `GET /suppliers` : Mengambil daftar rekanan pemasok.
- `POST /suppliers` : Menambah data pemasok (Owner).
- `PUT /suppliers/:id` : Mengedit pemasok (Owner).
- `DELETE /suppliers/:id` : Menghapus pemasok (Owner).
- `GET /purchases` : Daftar faktur pembelian grosir.
- `POST /purchases` : Mencatat faktur pembelian barang masuk & update stok (Owner).
- `GET /purchases/:id` : Rincian detail faktur pembelian dan item belanja.

### H. Sales & Point of Sale (POS)
- `GET /sales` : Riwayat penjualan (Owner: semua transaksi; Kasir: transaksi kasir terkait).
- `POST /sales` : Checkout penjualan ACID (cek stok, insert nota, mutasi stok, catat bayar).
- `GET /sales/:id` : Rincian nota penjualan dan item barang.
- `GET /sales/:id/receipt` : Data terformat khusus untuk cetak struk digital.
- `PATCH /sales/:id/void` : Pembatalan transaksi penjualan (Owner only, kembalikan stok).

### I. Customers
- `GET /customers` : Mengambil daftar pelanggan terdaftar.
- `POST /customers` : Mendaftarkan pelanggan baru.
- `PUT /customers/:id` : Mengubah data pelanggan.
- `DELETE /customers/:id` : Menghapus pelanggan.
- `GET /customers/:id/purchases` : Riwayat transaksi belanja pelanggan terkait.

### J. Expenses & Financial Reports
- `GET /expense-categories` : Daftar kategori pengeluaran operasional warung.
- `POST /expense-categories` : Menambah kategori pengeluaran (Owner).
- `GET /expenses` : Mengambil daftar catatan pengeluaran toko.
- `POST /expenses` : Mencatat pengeluaran baru (Owner).
- `PUT /expenses/:id` : Mengedit pengeluaran (Owner).
- `DELETE /expenses/:id` : Menghapus pengeluaran (Owner).
- `GET /reports/gross-profit` : Laporan Laba Kotor (Penjualan Bersih - HPP Snapshot).
- `GET /reports/financial` : Laporan Keuangan (Omset, HPP, Laba Kotor, Beban Operasional, Laba Bersih).
- `GET /reports/inventory` : Nilai valuasi aset stok gudang saat ini.

### K. Activity Audit Logs
- `GET /activity-logs` : Riwayat jejak audit aktivitas (Owner only).
