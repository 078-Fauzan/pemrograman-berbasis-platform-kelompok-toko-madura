# LAPORAN IMPLEMENTASI & PENGUJIAN 3-ROLE & MULTIPLATFORM (MOBILE, WEB, DESKTOP)
## SISTEM INFORMASI BISNIS WARUNG MADURA & KELONTONG (UMKMATE)

Tanggal Implementasi: 7 November 2026  
Platform Target: Mobile (Android/iOS), Web (Chrome/Edge), Desktop (Windows)  
Status Pengujian: **10/10 PASS (100% SUKSES)**  
Status Kompilasi Web: **BUILT SUCCESS (`build/web`)**

---

## 1. Ringkasan Implementasi 3 Peran (Role)

Sistem telah berhasil diperluas menjadi **3 Peran Utama** dengan hak akses yang terisolasi dan aman:

### A. Role 1 — Admin / Pemilik Toko (Owner)
- **Akun Demo**: `admin@umkmate.com` / `Password123!`
- **Akses**: Semua modul sistem tanpa batasan.
- **Fitur Tersedia**:
  1. Dashboard Finansial: Metrik omset, jumlah transaksi, grafik fl_chart tren penjualan 7 hari, peringatan stok menipis, dan produk terlaris.
  2. Master Produk & Kategori: CRUD produk lengkap beserta input Harga Modal (HPP / Cost Price), Harga Jual, dan Barcode.
  3. Kasir POS: Akses penuh ke layar Point of Sale untuk melayani pembeli langsung di warung.
  4. Manajemen Pesanan Toko: Menerima, mengonfirmasi, dan memproses pesanan online yang masuk dari pembeli.
  5. Manajemen Pengguna & Kasir: Menambah akun kasir baru, mengaktifkan/menonaktifkan kasir, serta profil toko.

### B. Role 2 — Kasir (Cashier)
- **Akun Demo**: `kasir1@umkmate.com` / `Password123!`
- **Akses**: Fokus pada operasional transaksi toko.
- **Fitur Tersedia**:
  1. Layar Kasir POS (Point of Sale): Pencarian produk cepat, filter kategori, keranjang kasir, diskon nota, kalkulasi uang diterima dan uang kembalian secara otomatis, serta cetak struk nota digital.
  2. Antrean Pesanan Toko: Melihat pesanan mandiri pembeli yang memilih "Ambil di Toko" atau "Antar ke Rumah", serta memperbarui statusnya.
  3. Katalog Produk Kasir: Melihat stok barang dan harga jual (field `cost_price` disembunyikan secara otomatis oleh backend).
  4. Ringkasan Shift Kasir: Rekapitulasi transaksi pada shift kasir yang sedang aktif.

### C. Role 3 — Pengunjung / Pembeli (Customer)
- **Akun Demo**: `customer@umkmate.com` / `Password123!`
- **Akses**: Pengalaman belanja mandiri.
- **Fitur Tersedia**:
  1. Registrasi Akun Pembeli: Formulir pendaftaran mandiri (Nama, No HP/WA, Email, Password, Alamat Rumah) tanpa membuat entitas toko baru.
  2. Etalase Produk Warung: Katalog belanja interaktif dengan filter kategori sembako, minuman, makanan ringan, sabun, dll.
  3. Keranjang Belanja Mandiri (Cart): Tambah/kurang kuantitas barang, hitung subtotal otomatis, dan hapus item.
  4. Checkout Pesanan: Pilihan opsi "Ambil di Toko" (Takeaway) atau "Diantar ke Rumah" (Delivery), input catatan pembeli, dan metode pembayaran (Tunai/COD atau QRIS).
  5. Riwayat & Pelacakan Pesanan: Memantau status pesanan (Menunggu Konfirmasi -> Sedang Disiapkan -> Siap Diambil/Diantar -> Selesai).
  6. Profil Pembeli: Pengaturan data diri dan alamat pengiriman default.

---

## 2. Hasil Eksekusi Uji Coba Backend (Automated Test Suite)

Pengujian dijalankan melalui script `backend/test-3roles.js`:

| No | Kasus Uji (Test Case) | Metode & Endpoint | Harapan | Hasil Aktual | Status |
|:--:|---|---|---|---|:--:|
| 1 | Health Check REST API | `GET /health` | HTTP 200, Aktif | HTTP 200, Status OK | **PASS** |
| 2 | Login Admin | `POST /auth/login` | Role `admin` / `owner` | HTTP 200, JWT Claim Valid | **PASS** |
| 3 | Login Kasir | `POST /auth/login` | Role `cashier` | HTTP 200, JWT Claim Valid | **PASS** |
| 4 | Login Customer | `POST /auth/login` | Role `customer` | HTTP 200, JWT Claim Valid | **PASS** |
| 5 | Registrasi Customer Baru | `POST /auth/register-customer` | Akun pembeli baru terbit | HTTP 201 Created | **PASS** |
| 6 | Pembuatan Pesanan oleh Customer | `POST /orders` | Verifikasi harga & stok | HTTP 201, Nomor Order Terbit | **PASS** |
| 7 | Riwayat Pesanan Customer | `GET /orders` (Customer) | Hanya data milik user sendiri | HTTP 200, Terisolasi Sempurna | **PASS** |
| 8 | Kasir/Admin Melihat Seluruh Pesanan | `GET /orders` (Kasir/Admin) | Menampilkan pesanan toko | HTTP 200, Array Lengkap | **PASS** |
| 9 | Kasir Konfirmasi Status Pesanan | `PATCH /orders/:id/status` | Status `confirmed` | HTTP 200, Status Berubah | **PASS** |
| 10| Role Guard: Customer Ditolak Update Status | `PATCH /orders/:id/status` | HTTP 403 Forbidden | HTTP 403 Akses Ditolak | **PASS** |

---

## 3. Hasil Kompilasi & Multiplatform Verification

- **Flutter Analyzer**: 0 Errors pada seluruh basis kode `lib/`.
- **Flutter Web Build**: Berhasil dikompilasi dengan output produksi di `mobile/build/web/` (`index.html`, `main.dart.js`, `assets/`, `canvaskit/`).
- **Responsive Breakpoint Layout**:
  - Layar HP / Mobile (< 700px): Bottom Navigation Bar, single/double column feed.
  - Layar Tablet / Desktop (≥ 700px): Permanent Sidebar Navigation, Multi-column layout, Master-Detail panel untuk Kasir POS.
- **Konektivitas Jaringan Adaptif**:
  - Otomatis `localhost:5000` untuk Web & Desktop.
  - Opsi konfigurasi IP LAN pada aplikasi untuk pengujian di smartphone Android/iOS fisik.
