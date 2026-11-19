# UMKMate — Sistem Informasi Manajemen Warung Madura & Toko Kelontong

[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-blue.svg)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/Backend-Node.js%20%26%20Express-green.svg)](https://nodejs.org)
[![Database](https://img.shields.io/badge/Database-MySQL%208.4-orange.svg)](https://www.mysql.com)
[![License](https://img.shields.io/badge/License-Academic-lightgrey.svg)](#)

Aplikasi manajemen operasional bisnis ritel modern untuk Warung Madura dan toko kelontong. Proyek ini dikembangkan sebagai Proyek Akhir mata kuliah **Praktikum Pemrograman Berbasis Platform**.

---

## 👥 Identitas Kelompok & Pembagian Peran

| No | Nama Mahasiswa | NIM | Akun GitHub | Peran / Tanggung Jawab |
|:--:|----------------|:---:|:-----------:|-------------------------|
| 1 | **Fauzan** | 078 | [@078-Fauzan](https://github.com/078-Fauzan) | **Project Lead & Full-Stack Developer** (Arsitektur Sistem, Database MySQL, Backend Express API, Frontend Flutter) |
| 2 | *(Anggota 2)* | *(NIM)* | *@github_user* | Frontend Developer (UI/UX Design, Svelte Web & Flutter Mobile Integration) |
| 3 | *(Anggota 3)* | *(NIM)* | *@github_user* | Quality Assurance & Documentation (Pengujian API, Video Demo, Laporan Akhir) |

> *Catatan: Tabel pembagian peran dan rincian kontribusi lebih detail tersedia di [docs/tugas-kelompok-1-kelompok.md](docs/tugas-kelompok-1-kelompok.md).*

---

## 🎯 Gambaran Proyek

**UMKMate** membantu pemilik Warung Madura dan toko kelontong mengelola penjualan, stok barang, kasir (POS), pembelian barang, pelanggan, supplier, pengeluaran operasional, serta laporan keuangan melalui satu ekosistem terintegrasi:

- **Mobile App (Flutter):** Aplikasi mobile untuk Kasir dan Owner dengan navigasi intuitif, Material Design 3, dan dukungan cetak struk serta barcode scanning.
- **Backend (Express.js REST API):** Menyediakan endpoint RESTful aman dengan autentikasi JWT, hashing bcrypt, role-based authorization (Owner & Cashier), dan isolasi toko (*multi-tenant store isolation*).
- **Database (MySQL):** Skema ternormalisasi dengan 16 tabel relasional, foreign key constraints, indexes, dan integritas data transaksi.

---

## 🏗️ Struktur Repository

Mengikuti standar pedoman [Praktikum Pemrograman Berbasis Platform](https://pemrograman-platform.vercel.app/modul-praktikum/cara-pengerjaan-tugas.html):

```text
pemrograman-berbasis-platform-kelompok-toko-madura/
├── docs/                                 # Dokumen laporan & pengujian
│   ├── tugas-kelompok-1-kelompok.md      # Identitas dan pembagian peran anggota
│   ├── proposal.md                       # Masalah, pengguna sasaran, ide solusi
│   ├── backlog.md                        # Daftar pekerjaan, prioritas, PIC, status
│   ├── tautan-video-pengujian.md         # Tabel link video pengujian & QA
│   └── Laporan-Kelompok-Toko-Madura.docx # Laporan proyek akhir
├── backend/                              # REST API Node.js + Express
│   ├── src/                              # Source code (controller, service, routes)
│   ├── .env.example                      # Template konfigurasi environment
│   ├── package.json                      # Dependensi backend
│   ├── server.js                         # Entry point server
│   └── README.md                         # Panduan eksekusi backend
├── database/                             # Skema SQL & data seed
│   ├── umkmate_db.sql                    # Skema DDL 16 tabel & relasi FK
│   └── seed.sql                          # Data demo awal
├── frontend/                             # Modul antarmuka platform
│   ├── web/                              # Web Dashboard (Svelte / HTML)
│   │   └── README.md
│   └── mobile/                           # Panduan dan artefak aplikasi mobile
│       └── README.md
├── mobile/                               # Aplikasi Mobile Flutter (Android)
│   ├── lib/                              # Source code Flutter (Provider, MVC/Clean)
│   ├── pubspec.yaml                      # Dependensi Flutter
│   └── README.md
├── documentation/                        # Dokumentasi teknis sistem lengkap (ERD, API, UI/UX)
├── .github/                              # Template Issue dan Pull Request
│   ├── ISSUE_TEMPLATE/kendala.md
│   └── pull_request_template.md
├── CONTRIBUTING.md                       # Pedoman commit, branch, dan PR
└── README.md                             # Berkas dokumentasi utama ini
```

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat Lingkungan
- **Node.js** >= v18
- **MySQL Server** >= 8.0 (disarankan via Laragon atau XAMPP)
- **Flutter SDK** >= 3.22 (untuk aplikasi Android)
- **Android Studio / Device Android** dengan USB Debugging aktif

---

### 2. Konfigurasi Basis Data (MySQL)

1. Buka MySQL client (Laragon / phpMyAdmin / MySQL CLI).
2. Buat database bernama `umkmate_db`:
   ```sql
   CREATE DATABASE IF NOT EXISTS umkmate_db;
   ```
3. Impor struktur tabel dan data seed:
   ```powershell
   Get-Content "database\umkmate_db.sql" -Raw | & "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root
   Get-Content "database\seed.sql" -Raw | & "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe" -u root
   ```

---

### 3. Menjalankan Backend API

1. Masuk ke folder backend:
   ```bash
   cd backend
   ```
2. Pasang dependensi:
   ```bash
   npm install
   ```
3. Konfigurasi berkas `.env` (salin dari `.env.example`):
   ```bash
   cp .env.example .env
   ```
   Pastikan pengaturan port, host, user, dan nama basis data sesuai:
   ```env
   PORT=5000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=
   DB_NAME=umkmate_db
   JWT_SECRET=umkmate_super_secret_jwt_key_2026_warung_madura_secure
   ```
4. Jalankan server:
   ```bash
   node server.js
   ```
5. Periksa status kesehatan API:
   Buka browser atau uji via curl: `http://localhost:5000/api/v1/health`

---

### 4. Menjalankan Aplikasi Mobile (Flutter Android)

1. Masuk ke folder `mobile`:
   ```bash
   cd mobile
   ```
2. Pasang dependensi Flutter:
   ```bash
   flutter pub get
   ```
3. Sesuaikan alamat IP backend pada `lib/core/constants/api_endpoints.dart`:
   Gunakan IP lokal laptop Anda (misal `http://192.168.0.102:5000/api/v1`) agar HP Android dapat terhubung melalui satu jaringan Wi-Fi.
4. Jalankan aplikasi pada perangkat Android fisik atau emulator:
   ```bash
   flutter run
   ```
5. Atau kompilasi file APK Debug:
   ```bash
   flutter build apk --debug
   ```
   File APK tersimpan di `mobile/build/app/outputs/flutter-apk/app-debug.apk`.

---

## 🔐 Akun Demo untuk Pengujian

Gunakan akun berikut untuk menguji hak akses role pada aplikasi:

| Role Pengguna | Email | Kata Sandi | Deskripsi Akses |
|:-------------|:------|:-----------|:----------------|
| **Owner (Pemilik Toko)** | `owner@umkmate.com` | `Password123!` | Akses penuh dashboard analitik, kelola kasir, produk, laporan laba rugi, supplier, dan profil toko |
| **Kasir 1** | `kasir1@umkmate.com` | `Password123!` | Akses dashboard kasir, katalog produk, Point of Sale (POS), checkout penjualan, dan riwayat transaksi pribadi |
| **Kasir 2** | `kasir2@umkmate.com` | `Password123!` | Akun kasir kedua untuk pengujian multi-kasir |

---

## 📹 Video Pengujian & Dokumentasi

- **Tautan Pengujian & QA:** Lihat [docs/tautan-video-pengujian.md](docs/tautan-video-pengujian.md)
- **Spesifikasi API Endpoint:** Lihat [documentation/API-Documentation.md](documentation/API-Documentation.md)
- **Diagram Relasi Entitas (ERD):** Lihat [documentation/ERD.md](documentation/ERD.md)
- **Desain UI/UX & Flow:** Lihat [documentation/UI-UX-Design.md](documentation/UI-UX-Design.md)

---

## 📜 Lisensi & Aturan Kontribusi
Setiap commit, pembuatan branch, dan pengajuan Pull Request wajib mengikuti aturan yang tercantum pada [CONTRIBUTING.md](CONTRIBUTING.md).
