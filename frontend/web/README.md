# Frontend Web — UMKMate (Sistem Informasi Warung Madura)

Antarmuka web untuk sistem manajemen operasional Warung Madura dan Toko Kelontong UMKMate.

---

## 🎯 Fitur & Kemampuan Versi Web
- **Dashboard Pemilik Toko (Owner):** Visualisasi omset penjualan harian/bulanan, kartu ringkasan transaksi, grafik penjualan 7 hari, dan peringatan stok menipis.
- **Katalog & Manajemen Produk:** Kelola harga jual, harga modal (HPP), kategori barang, dan stok minimum.
- **Kasir Point of Sale (POS):** Antarmuka kasir responsif untuk browser desktop dengan kalkulasi subtotal dan diskon otomatis.
- **Antarmuka Responsif:** Menggunakan tata letak adaptif desktop dengan sidebar navigasi di sebelah kiri pada layar lebar.
- **Resolusi Host Dinamis:** Otomatis menyesuaikan endpoint API sesuai host pemanggil (`localhost:5000` atau IP LAN `192.168.0.x:5000`).

---

## 🛠️ Cara Menjalankan Versi Web

### Opsi 1: Menggunakan Web Server Lokal (Port 8080)
1. Dari folder root proyek:
   ```bash
   python -m http.server 8080 --directory "mobile/build/web"
   ```
2. Atau dari folder `frontend/web`:
   ```bash
   npm start
   ```
3. Buka browser pada alamat:
   - Akses lokal di komputer: [http://localhost:8080](http://localhost:8080)
   - Akses via jaringan Wi-Fi LAN: `http://192.168.0.102:8080`

### Opsi 2: Menjalankan via Flutter Web (Mode Pengembangan)
1. Masuk ke folder `mobile`:
   ```bash
   cd mobile
   ```
2. Jalankan di browser Google Chrome:
   ```bash
   flutter run -d chrome
   ```
3. Atau kompilasi bundel produksi web:
   ```bash
   flutter build web
   ```
   Hasil kompilasi tersimpan di `mobile/build/web`.
