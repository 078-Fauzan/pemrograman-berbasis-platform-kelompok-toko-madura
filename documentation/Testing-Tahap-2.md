# LAPORAN PENGUJIAN TAHAP 2 — DATABASE DAN BACKEND DASAR
## SISTEM INFORMASI BISNIS UMKMATE

Tanggal Pengujian: 31 Oktober 2026  
Lingkungan: Windows 11, Node.js v24.13.0, MySQL v8.4.3 (Laragon)  
Port Server: `http://localhost:5000/api/v1`  
Total Test Cases: 22  
Hasil: **22 PASS / 0 FAIL (100% SUKSES)**

---

## 1. Rincian Hasil Eksekusi Test Suite

| No | Kasus Uji (Test Case) | Metode & Endpoint | Harapan | Hasil Aktual | Status |
|:--:|---|---|---|---|:--:|
| 1 | Health Check API | `GET /health` | HTTP 200, Status OK | HTTP 200, Aktif | **PASS** |
| 2 | Login Owner Demo | `POST /auth/login` | HTTP 200, Mengembalikan JWT | HTTP 200, JWT Valid | **PASS** |
| 3 | Login Kasir Demo | `POST /auth/login` | HTTP 200, Role `cashier` | HTTP 200, Role Valid | **PASS** |
| 4 | Login Password Salah | `POST /auth/login` | HTTP 401 Unauthorized | HTTP 401 Unauthorized | **PASS** |
| 5 | Akses Tanpa Token | `GET /auth/me` | HTTP 401 Unauthorized | HTTP 401 Unauthorized | **PASS** |
| 6 | Profil Pengguna Terautentikasi | `GET /auth/me` | HTTP 200, Data Profil | HTTP 200, Identitas Sesuai | **PASS** |
| 7 | Update Profil Toko & Owner | `PUT /auth/profile` | HTTP 200, Data Terupdate | HTTP 200, Updated | **PASS** |
| 8 | Role Guard: Kasir Akses `/users` | `GET /users` | HTTP 403 Forbidden | HTTP 403 Forbidden | **PASS** |
| 9 | Owner Akses Daftar Kasir | `GET /users` | HTTP 200, List Kasir | HTTP 200, Array Data | **PASS** |
| 10 | Owner Tambah Kasir Baru | `POST /users` | HTTP 201 Created | HTTP 201 Created | **PASS** |
| 11 | Owner Nonaktifkan Kasir | `PATCH /users/:id/status` | HTTP 200, `is_active: 0` | HTTP 200, Dinonaktifkan | **PASS** |
| 12 | Kasir Nonaktif Coba Login | `POST /auth/login` | HTTP 403 Forbidden | HTTP 403 Akun Dinonaktifkan | **PASS** |
| 13 | Owner Aktifkan Kembali Kasir | `PATCH /users/:id/status` | HTTP 200, `is_active: 1` | HTTP 200, Diaktifkan | **PASS** |
| 14 | Registrasi Toko & Owner Baru | `POST /auth/register` | HTTP 201 via ACID Tx | HTTP 201 Store ID Baru Terbit | **PASS** |
| 15 | Multi-Tenant Data Isolation | `GET /products` (Toko Baru) | Hanya data milik toko sendiri | HTTP 200, Array Kosong (Terisolasi) | **PASS** |
| 16 | Proteksi HPP untuk Kasir | `GET /products` (Kasir) | Field `cost_price` disembunyikan | HTTP 200, `cost_price` undefined | **PASS** |
| 17 | Pemindaian Barcode Produk | `GET /products/barcode/:code`| HTTP 200, Temukan Le Minerale | HTTP 200, Barcode Cocok | **PASS** |
| 18 | Dashboard Analitik Owner | `GET /dashboard` | HTTP 200, Metrik Real-time | HTTP 200, Metrik Lengkap | **PASS** |
| 19 | Role Guard: Kasir Akses Dashboard | `GET /dashboard` | HTTP 403 Forbidden | HTTP 403 Forbidden | **PASS** |
| 20 | Permintaan Lupa Password | `POST /auth/forgot-password` | HTTP 200, Generate Reset Token | HTTP 200, Token Dihasilkan | **PASS** |
| 21 | Eksekusi Reset Password | `POST /auth/reset-password` | HTTP 200, Password Diubah | HTTP 200, Sukses Diperbarui | **PASS** |
| 22 | Login dengan Password Baru | `POST /auth/login` | HTTP 200 Berhasil Masuk | HTTP 200 Login Berhasil | **PASS** |

---

## 2. Kesimpulan Kualitas

1. **Integritas Database:** Skema DDL 16 tabel dan data awal demo terverifikasi berfungsi sempurna dengan foreign key, indexes, dan constraints.
2. **Keamanan:** Password terenkripsi dengan bcrypt, otentikasi JWT stateless berjalan mulus, dan otorisasi role guard berhasil memblokir akses kasir ke fitur sensitif owner.
3. **Isolasi Data (Multi-Tenancy):** `store_id` diverifikasi langsung dari klaim token dan sepenuhnya mengisolasi data antar toko.
