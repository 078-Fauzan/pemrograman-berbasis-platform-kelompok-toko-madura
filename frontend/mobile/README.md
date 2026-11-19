# Frontend Mobile Application — UMKMate

Modul aplikasi mobile berbasis Android yang dikembangkan menggunakan **Flutter** dan **Dart**.

> ℹ️ *Catatan: Source code lengkap proyek Flutter terletak pada folder root [`/mobile`](../../mobile).*

---

## 🎯 Fitur Aplikasi Mobile
- **Autentikasi & Keamanan:** Login Owner & Kasir, Register Toko Baru, Penyimpanan Token Aman via `SharedPreferences`.
- **Role-Based Dynamic Navigation:** Tampilan dashboard dan menu navigasi bawah menyesuaikan role pengguna (Owner vs Kasir).
- **Point of Sale (POS):** Antarmuka kasir cepat, kalkulasi subtotal otomatis, dan manajemen keranjang belanja.
- **Katalog & Stok Produk:** Daftar produk dengan filter kategori, pencarian real-time, dan status stok minimum.
- **Visualisasi Statistik:** Grafik fl_chart tren omset harian dan kartu statistik ringkasan penjualan.

---

## 🛠️ Arsitektur & Paket Utama
- **State Management:** `provider`
- **Network HTTP:** `http` dengan bearer token interceptor
- **Penyimpanan Lokal:** `shared_preferences`
- **Grafik:** `fl_chart`
- **Format Mata Uang & Tanggal:** `intl` (Rupiah & format Indonesia)
- **Tipografi:** `google_fonts` (Plus Jakarta Sans / Poppins)

---

## 🚀 Cara Menjalankan Aplikasi
1. Masuk ke direktori `mobile`:
   ```bash
   cd mobile
   ```
2. Ambil paket dependensi:
   ```bash
   flutter pub get
   ```
3. Pastikan konfigurasi IP pada `lib/core/constants/api_endpoints.dart` mengarah ke alamat IP server backend lokal laptop Anda.
4. Hubungkan smartphone Android (USB Debugging aktif) atau Emulator.
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```
6. Bangun berkas APK:
   ```bash
   flutter build apk --debug
   ```
