# RANCANGAN UI/UX APLIKASI UMKMATE

Aplikasi **UMKMate** dirancang khusus untuk kenyamanan dan kecepatan operasional Warung Madura dan Toko Kelontong, memadukan estetika modern **Material Design 3** dengan kepraktisan transaksi kasir fisik.

---

## 1. Desain Sistem & Panduan Visual

### Palet Warna (Color Palette)
- **Primary Color:** `#006D40` (Forest Emerald — mencerminkan kemakmuran, kestabilan, dan warna khas UMKM Madura).
- **Primary Container:** `#D1E8D5` (Soft Mint Container).
- **Secondary Color:** `#10B981` (Vibrant Mint — untuk tombol aksi, badge status sukses).
- **Background / Surface:** `#F8FAFC` (Neutral Clean Gray/White — nyaman di mata untuk penggunaan berjam-jam).
- **Card & Dialog Surface:** `#FFFFFF` (Pure White dengan border halus `#E2E8F0`).
- **Error / Danger:** `#DC2626` (Red — untuk stok habis, transaksi void, tombol hapus).
- **Warning:** `#F59E0B` (Amber — untuk stok menipis mendekati minimum).
- **Text Primary:** `#0F172A` (Slate 900 — keterbacaan tinggi).
- **Text Secondary:** `#64748B` (Slate 500).

### Tipografi
- Font Family: **Plus Jakarta Sans** atau **Inter** (via `google_fonts`).
- Ukuran teks utama proporsional dan jelas:
  - Header: 20-24sp Bold
  - Subheader: 16sp Semi-Bold
  - Body: 14sp Regular
  - Caption / Meta: 12sp Regular

### Konvensi Format
- **Mata Uang:** Format Rupiah standar Indonesia: `Rp 25.000` (tanpa desimal nol berlebih).
- **Tanggal & Waktu:** Format Bahasa Indonesia: `31 Okt 2026, 14:30 WIB`.

---

## 2. Peta Navigasi & Struktur Layar

Aplikasi menggunakan pendekatan **Role-Adaptive Dynamic Navigation**. Saat login berhasil, Bottom Navigation Bar menyesuaikan secara dinamis:

```
[ APLIKASI UMKMATE ]
         │
         ├── AUTH FLOW
         │     ├── Splash Screen (Branding & Cek Token)
         │     ├── Onboarding (Pengenalan Fitur UMKMate)
         │     ├── Login (Email, Password, Role Detection)
         │     ├── Register Toko & Owner (Buka Toko Baru)
         │     └── Lupa Password (Reset Token)
         │
         ├── OWNER FLOW (Full Management)
         │     ├── Tab 1: Dashboard (Omset, Grafik fl_chart, Stok Alert)
         │     ├── Tab 2: Kasir POS (Katalog, Keranjang, Checkout, Bayar)
         │     ├── Tab 3: Produk & Stok (Katalog, Tambah/Edit, Kategori, In/Out)
         │     ├── Tab 4: Keuangan (Pengeluaran, Laba Kotor, Lap. Keuangan)
         │     └── Tab 5: Akun & Toko (Profil Toko, Kelola Kasir, Pemasok, Pelanggan, Audit Log)
         │
         └── KASIR FLOW (Penjualan Khusus)
               ├── Tab 1: Kasir POS (Scan Barcode, Keranjang Cepat, Checkout)
               ├── Tab 2: Riwayat Transaksi (Nota Shift Kasir Terkait)
               └── Tab 3: Profil Kasir (Info Kasir, Tutup Shift / Logout)
```

---

## 3. Rincian Wireframe & Tata Letak Seluruh Halaman Utama

### A. Alur Autentikasi
1. **Splash Screen:**
   - Tampilan logo UMKMate, slogan "Sahabat Pengusaha Warung & Kelontong", indikator loading.
   - Pengecekan otomatis token JWT di `flutter_secure_storage`.
2. **Onboarding Screen:**
   - 3 Carousel slide visual:
     1. "Manajemen Warung Lebih Rapi & Akurat"
     2. "Kasir Digital Cepat dengan Scan Barcode"
     3. "Pantau Laba Kotor & Stok Real-Time"
   - Tombol "Mulai Sekarang" menuju Login / Register.
3. **Register Toko:**
   - Card formulir: Nama Toko, Nama Pemilik, Email, No. WhatsApp, Password & Konfirmasi.
   - Tombol "Daftarkan Toko Saya".
4. **Login:**
   - Input Email & Password dengan toggle lihat/sembunyikan password.
   - Tautan "Lupa Password?".
   - Tombol "Masuk ke UMKMate".
5. **Lupa Password:**
   - Input email terdaftar untuk menerima instruksi reset token verifikasi.

---

### B. Halaman Owner (Pemilik Toko)
1. **Dashboard Owner:**
   - **Header:** Nama Toko, Tanggal hari ini, Icon Notifikasi (dengan badge merah jika stok menipis).
   - **Banner Kartu Metrik:**
     - Penjualan Hari Ini (`Rp 1.450.000`)
     - Jumlah Transaksi (`38 Transaksi`)
     - Total Produk Aktif (`142 Produk`)
     - Peringatan Stok Menipis (`4 Produk`)
   - **Grafik Tren Penjualan:** Garis atau Bar chart interaktif (`fl_chart`) 7 hari terakhir.
   - **Daftar Produk Terlaris:** Top 5 produk dengan jumlah penjualan tertinggi.
   - **Aksi Cepat:** Tombol shortcut: "Tambah Produk", "Catat Stok Masuk", "Catat Pengeluaran".
2. **Katalog Produk:**
   - Search bar dengan icon scan barcode di kanan.
   - Horizontal category chips (Semua, Sembako, Minuman, Rokok, Makanan, dsb).
   - Card List Produk: Foto/Icon kategori, Nama Produk, Barcode, Stok (badge merah jika <= min_stock), Harga Jual.
   - Floating Action Button (FAB) "+ Tambah Produk".
3. **Tambah & Edit Produk:**
   - Form input: Barcode (bisa diisi manual atau tombol scan kamera), Nama Produk, Dropdown Kategori, Satuan (Pcs/Bungkus/Kg), Harga Modal (HPP), Harga Jual, Stok Awal, Batas Minimum Stok.
   - Tombol simpan dengan feedback snackbar sukses.
4. **Kategori Produk:**
   - Daftar kategori toko dengan jumlah produk terkait.
   - Dialog tambah/ubah nama kategori.
5. **Inventaris & Manajemen Stok:**
   - Ringkasan total nilai stok toko (Asset Value = sum(stock * cost_price)).
   - Filter tab: "Semua Stok", "Stok Menipis", "Stok Habis".
   - Opsi: "Catat Stok Masuk" dan "Catat Stok Keluar".
6. **Form Stok Masuk & Stok Keluar:**
   - Pilih produk, masukkan jumlah barang yang masuk/keluar, pilih alasan (Rusak / Kadaluarsa / Konsumsi / Penyesuaian Opname), dan catatan.
7. **Riwayat Mutasi Stok (`stock_movements`):**
   - Timeline log pergerakan stok: Tanggal, Nama Produk, Kuantitas (+/-), Tipe (Penjualan / Pembelian / Opname), Nama Staf/Kasir.
8. **Scan Barcode Cepat:**
   - Viewfinder kamera dengan garis pemindai laser merah.
   - Begitu barcode terdeteksi -> getar haptic -> buka langsung detail produk atau masukkan ke keranjang.
9. **Manajemen Pemasok & Pembelian:**
   - Daftar supplier grosir dengan tombol telepon/WhatsApp langsung.
   - Form pencatatan pembelian grosir baru (faktur masuk, tambah beberapa item produk, catat total belanja, update stok otomatis).
10. **Manajemen Pelanggan:**
    - Daftar pelanggan setia warung, nomor kontak, total akumulasi belanja.
11. **Pencatatan Biaya Pengeluaran (`expenses`):**
    - Input: Kategori (Listrik, Sewa, Plastik, Operasional), Deskripsi, Nominal (Rp), Tanggal.
    - Menampilkan riwayat pengeluaran bulanan.
12. **Laporan Laba Kotor (Gross Profit):**
    - Filter periode: Hari Ini, 7 Hari, Bulan Ini, Kustom.
    - Card Kartu:
      - Total Penjualan Bersih (Omset)
      - Total HPP (Harga Pokok Penjualan dari Snapshot Modal)
      - **Laba Kotor (Gross Profit)**
      - Margin Persentase (`(Laba Kotor / Penjualan) * 100%`)
13. **Laporan Keuangan Komprehensif:**
    - Laba Kotor - Total Biaya Pengeluaran = **Laba Bersih Operasional**.
    - Rincian breakdown pengeluaran terbesar per kategori.
14. **Manajemen Akun Kasir:**
    - Daftar kasir toko dengan status badge (Aktif / Nonaktif).
    - Tombol tambah kasir (Input: Nama Kasir, Email, Password sementara, No HP).
    - Switch toggle untuk menonaktifkan akun kasir sewaktu-waktu.
15. **Audit Log Aktivitas Toko:**
    - Riwayat jejak rekam aktivitas staf (Waktu, Nama User, Aksi: Login, Void Nota, Ubah Harga).
16. **Profil & Pengaturan Toko:**
    - Pengaturan Nama Warung, Alamat, No Telepon, Pesan Catatan Struk (Contoh: "Terima kasih atas kunjungan Anda").

---

### C. Halaman Kasir (POS - Point of Sale)
1. **Dashboard Shift Kasir:**
   - Info nama kasir bertugas & jam mulai shift.
   - Ringkasan: Total Transaksi Shift Ini & Total Uang Masuk Shift Ini.
   - Tombol besar: "Mulai Melayani / Buka Kasir".
2. **Katalog Kasir & Keranjang:**
   - Layout responsif: Katalog produk di atas, floating badge keranjang belanja di bawah.
   - Search bar real-time + Tombol Scan Barcode Camera.
   - Setiap card produk memiliki tombol cepat sentuh untuk menambahkan ke keranjang.
3. **Bottom Sheet / Layar Keranjang Belanja:**
   - Menampilkan daftar produk terpilih: Nama barang, kuantitas stepper `[-] [ 2 ] [+]`, harga satuan, subtotal.
   - Input Diskon Nota (opsional).
   - Ringkasan total pembayaran (Besar dan tebal).
   - Tombol "Lanjut ke Pembayaran".
4. **Layar Pembayaran (Payment Screen):**
   - Tampilan Total Belanja: Contoh `Rp 48.000`.
   - Pilihan Metode Pembayaran:
     - **Tunai (Cash):** Tombol pecahan uang pas (`Rp 50.000`, `Rp 100.000`, Uang Pas), atau input keyboard numerik.
     - Tampilan otomatis **Uang Kembalian** (Contoh: Uang `Rp 50.000`, Kembalian `Rp 2.000`).
     - **QRIS:** Tampilan konfirmasi pencatatan QRIS warung.
     - **Transfer Bank:** Pencatatan transfer.
   - Tombol aksi: "Selesaikan Transaksi".
5. **Struk Digital & Bukti Belanja:**
   - Desain nota thermal minimalis:
     - Header: UMKMate - [Nama Warung]
     - No. Faktur & Waktu Transaksi
     - Nama Kasir
     - Garis pemisah putus-putus
     - List barang: Kuantitas x Harga = Subtotal
     - Total, Tunai, Kembalian
     - Footer: Ucapan terima kasih
   - Tombol aksi:
     - "Bagikan via WhatsApp" (menggunakan `share_plus`)
     - "Cetak Struk"
     - "Transaksi Baru" (mengosongkan keranjang dan kembali ke katalog).
6. **Riwayat Penjualan Kasir:**
   - Hanya menampilkan transaksi yang dicetak oleh kasir yang bersangkutan.
   - Status transaksi `completed`.
   - Tombol untuk mencetak ulang struk digital jika pelanggan meminta.
