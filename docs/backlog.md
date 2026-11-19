# Backlog Pengerjaan Proyek — UMKMate

Daftar pekerjaan, skala prioritas, penanggung jawab (PIC), dan status perkembangan modul sistem:

| ID | Modul / Fitur | Deskripsi Pekerjaan | Prioritas | PIC | Status |
|:--:|---------------|---------------------|:---------:|:---:|:------:|
| **BL-01** | **Database Architecture** | Perancangan ERD 16 tabel relasional, constraint FK, indeks, dan migrasi SQL `umkmate_db.sql` | Tinggi | Fauzan | **Selesai** |
| **BL-02** | **Backend Auth & RBAC** | Implementasi autentikasi JWT, password hashing bcrypt, middleware role guard (Owner/Kasir), dan isolasi `store_id` | Tinggi | Fauzan | **Selesai** |
| **BL-03** | **Product & Category API** | Endpoint CRUD produk, upload/path gambar, filter kategori, pencarian nama, dan lookup barcode | Tinggi | Fauzan | **Selesai** |
| **BL-04** | **Sales & POS API** | Endpoint transaksi penjualan multi-item, kalkulasi subtotal, pengurangan stok otomatis via DB Transaction | Tinggi | Fauzan | **Selesai** |
| **BL-05** | **Dashboard & Reports API** | Endpoint agregasi ringkasan omset harian, chart penjualan 7 hari terakhir, dan laporan laba kotor | Sedang | Fauzan | **Selesai** |
| **BL-06** | **Flutter Project Setup** | Inisialisasi Flutter Material 3, tema warna Emerald Green, konfigurasi `ApiEndpoints` & `network_security_config` | Tinggi | Fauzan | **Selesai** |
| **BL-07** | **Auth Screens (Flutter)** | Tampilan Login, Register Toko, Splash Screen, simpan token di SharedPreferences | Tinggi | Fauzan | **Selesai** |
| **BL-08** | **Owner Dashboard UI** | Kartu metrik pendapatan, transaksi, grafik fl_chart, dan notifikasi stok menipis | Tinggi | Fauzan | **Selesai** |
| **BL-09** | **Kasir Dashboard & POS UI** | Antarmuka kasir cepat, pencarian produk, keranjang belanja, kalkulator kembalian | Tinggi | Fauzan | **Selesai** |
| **BL-10** | **Product Management UI** | Katalog produk grid/list, modal tambah/edit produk, dialog kelola kategori | Sedang | Anggota 2 | **Selesai** |
| **BL-11** | **Supplier & Customer UI** | Modul pencatatan data kontak supplier, riwayat pembelian barang, dan data pelanggan | Sedang | Anggota 2 | **Dalam Proses** |
| **BL-12** | **Expense Management UI** | Pencatatan pengeluaran operasional toko (listrik, sewa, gaji) dan integrasi ke laporan | Sedang | Anggota 2 | **Dalam Proses** |
| **BL-13** | **API Automated Testing** | Pembuatan skrip uji menyeluruh untuk 22+ skenario endpoint backend | Sedang | Anggota 3 | **Selesai** |
| **BL-14** | **Documentation & Video Demo**| Perekaman video uji fungsional, pengisian kuesioner pengalaman pengguna, dan laporan Word | Sedang | Anggota 3 | **Dalam Proses** |
