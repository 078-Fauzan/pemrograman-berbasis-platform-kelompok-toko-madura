# DAFTAR DEPENDENSI SISTEM UMKMATE

Dokumen ini memuat spesifikasi dependensi pustaka untuk Backend (Node.js) dan Frontend Mobile (Flutter).

---

## 1. Backend Dependensi (Node.js & Express)

### Runtime Dependencies (`dependencies` di `package.json`):
1. **`express` (^4.21.0):**
   - Web framework minimalis dan cepat untuk routing REST API.
2. **`mysql2` (^3.11.0):**
   - Driver database MySQL performa tinggi yang mendukung `async/await`, connection pooling, dan parameterized queries untuk proteksi SQL Injection.
3. **`jsonwebtoken` (^9.0.2):**
   - Implementasi JSON Web Token untuk otentikasi stateless antara aplikasi Flutter dan backend.
4. **`bcryptjs` (^2.4.3):**
   - Hashing dan verifikasi kata sandi dengan salt rounds kuat.
5. **`dotenv` (^16.4.5):**
   - Memuat variabel konfigurasi lingkungan dari file `.env`.
6. **`cors` (^2.8.5):**
   - Middleware untuk mengizinkan akses request dari alamat IP perangkat seluler.
7. **`express-validator` (^7.2.0):**
   - Sanitasi dan validasi ketat untuk request payload (body, query, params).
8. **`helmet` (^7.1.0):**
   - Middleware keamanan untuk mengamankan HTTP header.
9. **`morgan` (^1.10.0):**
   - HTTP request logger untuk monitoring dan debugging lalu lintas API.

### Development Dependencies (`devDependencies`):
1. **`nodemon` (^3.1.7):**
   - Auto-reload server selama masa pengembangan.

---

## 2. Mobile Dependensi (Flutter Android)

### Spesifikasi `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (Sesuai panduan arsitektur: Provider konsisten)
  provider: ^6.1.2

  # Networking & REST API
  http: ^1.2.2

  # Security & Local Storage
  flutter_secure_storage: ^9.2.2    # Penyimpanan aman token JWT (Keystore Android)
  shared_preferences: ^2.3.2        # Pengaturan lokal & status onboarding

  # Visualisasi & Grafik
  fl_chart: ^0.69.0                 # Visualisasi tren penjualan harian/mingguan/bulanan

  # Hardware Scanner
  mobile_scanner: ^6.0.2            # Pemindai barcode EAN-13/UPC/QR via kamera HP

  # Localization, Formatting & Fonts
  intl: ^0.19.0                     # Format mata uang Rupiah & format tanggal Indonesia
  google_fonts: ^6.2.1              # Tipografi modern Plus Jakarta Sans

  # Utilitas Pembagian Struk
  share_plus: ^10.1.0               # Membagikan struk digital via WhatsApp / PDF
  path_provider: ^2.1.4             # Akses direktori penyimpanan lokal

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```
