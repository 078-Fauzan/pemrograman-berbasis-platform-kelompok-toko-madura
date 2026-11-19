# PANDUAN PENGEMBANGAN DAN EKSEKUSI BACKEND UMKMATE

Backend **UMKMate** dibangun menggunakan Node.js dan Express.js, terhubung ke basis data MySQL (Laragon / MySQL lokal) dengan arsitektur REST API.

---

## 1. Prasyarat Lingkungan (Prerequisites)

- **Node.js:** Versi >= 18 (Rekomendasi v20+ atau v24)
- **MySQL Database:** Versi >= 8.0 (Tersedia otomatis via Laragon)
- **Port Tersedia:** `5000` (Backend API) dan `3306` (MySQL)

---

## 2. Struktur Konfigurasi `.env`

Salin file `.env.example` menjadi `.env` jika belum ada:
```bash
cp .env.example .env
```

Contoh isi `.env`:
```env
NODE_ENV=development
PORT=5000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=umkmate_db

JWT_SECRET=umkmate_super_secret_jwt_key_2026_warung_madura_secure
JWT_EXPIRES_IN=7d

CORS_ORIGIN=*
```

---

## 3. Langkah Menjalankan Backend (Windows PowerShell)

### A. Pastikan MySQL Laragon Berjalan
Pastikan tombol **Start All** di Laragon sudah diklik, atau pastikan service MySQL berjalan pada port `3306`.

### B. Impor Database dan Data Demo (Jika Belum)
Jalankan perintah berikut di PowerShell dari root proyek:
```powershell
# Impor struktur 16 tabel
Get-Content "c:\Project Flutter\toko_madura\database\umkmate_db.sql" -Raw | & "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root

# Impor data awal demo (Owner, Kasir, 32 Produk, 5 Kategori, Pelanggan, Pemasok)
Get-Content "c:\Project Flutter\toko_madura\database\seed.sql" -Raw | & "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root
```

### C. Masuk ke Folder Backend dan Jalankan Server
```powershell
cd "c:\Project Flutter\toko_madura\backend"

# Jalankan dalam mode produksi / standar
npm start

# ATAU jalankan dengan auto-reload (development)
npm run dev
```

Server akan aktif pada:
`http://localhost:5000/api/v1`

---

## 4. Akun Demo Bawaan untuk Pengujian

Semua akun demo di bawah ini menggunakan kata sandi: **`Password123!`**

| Peran (Role) | Nama Pengguna | Email | Hak Akses |
|---|---|---|---|
| **Owner** | Fauzan (Owner) | `owner@umkmate.com` | Akses penuh (Dashboard, Keuangan, Kasir, Produk, dsb) |
| **Kasir Pagi** | Ahmad Subarjo | `kasir1@umkmate.com` | Akses POS, scan barcode, riwayat shift sendiri |
| **Kasir Sore** | Siti Aminah | `kasir2@umkmate.com` | Akses POS, scan barcode, riwayat shift sendiri |

---

## 5. Ringkasan Endpoint Utama Tahap 2

| Method | Endpoint | Hak Akses | Keterangan |
|---|---|:---:|---|
| `GET` | `/api/v1/health` | Publik | Status kesehatan API |
| `POST` | `/api/v1/auth/register` | Publik | Registrasi toko dan owner baru |
| `POST` | `/api/v1/auth/login` | Publik | Login pengguna (Owner & Kasir) |
| `POST` | `/api/v1/auth/forgot-password` | Publik | Permintaan reset kata sandi |
| `POST` | `/api/v1/auth/reset-password` | Publik | Reset kata sandi baru |
| `GET` | `/api/v1/auth/me` | Autentikasi | Profil pengguna login saat ini |
| `PUT` | `/api/v1/auth/profile` | Autentikasi | Update profil pengguna & toko |
| `GET` | `/api/v1/users` | Owner | Daftar seluruh kasir toko |
| `POST` | `/api/v1/users` | Owner | Tambah kasir baru |
| `GET` | `/api/v1/users/:id` | Owner | Rincian data kasir |
| `PUT` | `/api/v1/users/:id` | Owner | Edit profil kasir |
| `PATCH` | `/api/v1/users/:id/status` | Owner | Toggle aktif/nonaktif akun kasir |
| `GET` | `/api/v1/categories` | Semua User | Daftar kategori produk |
| `POST` | `/api/v1/categories` | Owner | Tambah kategori produk |
| `GET` | `/api/v1/products` | Semua User | Katalog produk (Kasir: hanya produk aktif) |
| `GET` | `/api/v1/products/barcode/:code` | Semua User | Cari produk via barcode scanner |
| `POST` | `/api/v1/products` | Owner | Tambah master produk |
| `GET` | `/api/v1/dashboard` | Owner | Metrik KPI dashboard |
| `GET` | `/api/v1/dashboard/sales-chart` | Owner | Grafik penjualan 7 hari terakhir |
| `GET` | `/api/v1/notifications` | Semua User | Notifikasi sistem & stok menipis |
