# Proposal Proyek Akhir — UMKMate

## 1. Latar Belakang & Permasalahan

Warung Madura dan toko kelontong tradisional merupakan pilar penting dalam perekonomian mikro di Indonesia. Namun, sebagian besar pengelola toko kelontong menghadapi berbagai tantangan operasional:

1. **Pencatatan Penjualan Masih Konvensional:** Mayoritas transaksi masih dicatat menggunakan buku kas manual atau bahkan tidak dicatat sama sekali, berisiko tinggi terjadinya selisih kas dan salah hitung.
2. **Ketiadaan Pengawasan Stok Barang (Inventory Control):** Pemilik toko seringkali tidak mengetahui barang apa yang hampir habis (*low stock*), barang yang kedaluwarsa, atau barang yang paling laku (*best-seller*).
3. **Kesulitan Menghitung Laba-Rugi Bersih:** Karena pencatatan pengeluaran harian tercampur dengan uang pribadi, pemilik warung kesulitan mengetahui apakah operasional toko menghasilkan profit atau kerugian.
4. **Keterbatasan Pengawasan Multi-Kasir:** Pemilik warung yang mempekerjakan karyawan kasir sering khawatir terhadap kecurangan dan manipulasi harga karena tidak adanya sistem pembagian hak akses (*Role-Based Access Control*).

---

## 2. Pengguna Sasaran (Target User)

Aplikasi dirancang untuk melayani dua entitas pengguna utama dalam ekosistem toko kelontong:

1. **Owner (Pemilik Toko):**
   - Memiliki wewenang penuh atas operasional bisnis.
   - Mengawasi arus kas, laporan laba-rugi, dan analitik penjualan.
   - Mengelola katalog produk, harga modal, harga jual, kategori, dan pemasok.
   - Mengelola akun kasir serta mengawasi aktivitas transaksi kasir.

2. **Cashier (Karyawan Kasir Toko):**
   - Memproses transaksi penjualan Point of Sale (POS) harian dengan cepat.
   - Mencari produk melalui teks atau pemindaian barcode kamera.
   - Menerima pembayaran tunai/non-tunai dan menerbitkan struk transaksi digital.
   - Akses dibatasi secara ketat di backend agar tidak dapat memanipulasi data modal atau melihat data keuangan rahasia pemilik.

---

## 3. Ide Solusi

Mengembangkan **UMKMate**, sebuah sistem informasi manajemen warung dan toko kelontong terpadu yang memadukan aplikasi mobile Android (Flutter) dengan backend REST API (Node.js + Express) dan basis data relasional (MySQL):

- **Fitur Point of Sale (POS) Cepat & Efisien:** Memungkinkan kasir memindai barcode atau memilih barang secara visual, menghitung kembalian otomatis, serta mencatat penjualan dalam hitungan detik.
- **Isolasi Data Toko (Multi-Tenant Store Isolation):** Keamanan data tingkat tinggi di mana setiap record data diisolasi berdasarkan `store_id` yang diverifikasi secara kriptografis melalui JWT token.
- **Sistem Pengingat Stok Minimum & Notifikasi:** Memberikan peringatan dini kepada pemilik ketika persediaan barang berada di bawah ambang batas minimum.
- **Dashboard Analitik & Laporan Keuangan Otomatis:** Grafik tren omset harian/bulanan, rincian margin laba kotor, dan komparasi pendapatan versus pengeluaran operasional.
- **Arsitektur Multiplatform:** Fleksibilitas antarmuka di mana core backend dapat diakses dari smartphone Android kasir maupun dashboard web pengelola.

---

## 4. Alasan Pemilihan Topik

1. **Dampak Riil untuk UMKM:** Memberikan kontribusi nyata dalam percepatan digitalisasi warung kelontong tradisional agar mampu bersaing dengan minimarket modern berjaringan.
2. **Kesesuaian dengan Capaian Pembelajaran Praktikum:** Mencakup seluruh pilar kurikulum mata kuliah Pemrograman Berbasis Platform, mulai dari desain database relasional yang kompleks, arsitektur REST API dengan autentikasi berbasis role, manajemen state mobile (Provider), hingga integrasi client-server multiplatform.
