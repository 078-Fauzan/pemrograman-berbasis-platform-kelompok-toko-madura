# Panduan Kontribusi & Alur Kerja Git (Git Workflow)

Seluruh anggota kelompok wajib mengikuti panduan kontribusi ini sesuai dengan pedoman **Praktikum Pemrograman Berbasis Platform**.

---

## 1. Aturan Format Pesan Commit
Format pesan commit **wajib** mengikuti struktur konvensional berikut:

```text
<tipe>(<bagian>): <ringkasan perubahan>
```

### Tipe Commit yang Diizinkan:
- **`feat`** : Menambahkan tugas baru, modul, atau fitur fungsional.
- **`fix`** : Memperbaiki bug, error, atau kesalahan logika.
- **`docs`** : Menambahkan atau memperbarui dokumentasi (README, proposal, backlog, panduan).
- **`test`** : Menambahkan atau memperbarui skrip pengujian (unit test, API test, dsb).
- **`refactor`** : Mengubah struktur kode tanpa memengaruhi fungsionalitas.

### Contoh Pesan Commit:
```bash
feat(backend): implementasi autentikasi JWT dan middleware role
feat(mobile): tambah halaman katalog produk dengan filter kategori
fix(api): perbaiki validasi stok pada transaksi penjualan
docs(kelompok): perbarui backlog dan proposal proyek
test(backend): tambah pengujian otomatis 22 skenario endpoint
```

---

## 2. Penggunaan Branch & Alur Pull Request
1. **Branch Utama (`main`):** Hanya berisi kode yang sudah stabil dan siap dinilai. Tidak diperkenankan melakukan *direct push* ke `main` untuk fitur besar tanpa melalui review.
2. **Branch Tugas:** Buat branch baru untuk setiap fitur atau tugas tertentu:
   ```bash
   git checkout main
   git pull --ff-only
   git checkout -b <nama-branch-tugas>
   ```
3. **Kewajiban Push & Pull Request:**
   - Setelah menyelesaikan tugas, lakukan commit terfokus dan push branch ke GitHub.
   - Ajukan **Pull Request (PR)** dengan target base `main`.
   - Isi ringkasan, perubahan berkas, dan langkah pengujian sesuai `pull_request_template.md`.
   - Minta review dari anggota kelompok lain sebelum menggabungkan (*merge*).

---

## 3. Kebersihan dan Keamanan Repositori
- **DILARANG KERAS** menyertakan file kredensial rahasia: file `.env` asli, token API rahasia, password database, dsb. Gunakan selalu `.env.example`.
- **DILARANG KERAS** mengikutsertakan folder dependensi atau cache kompilasi ke dalam repositori:
  - `node_modules/`
  - `.dart_tool/`
  - `build/`
  - `.gradle/`

---

## 4. Pencatatan Kendala (GitHub Issues)
Setiap kendala teknis, hambatan lingkungan (*environment*), atau bug yang ditemukan selama pengerjaan **wajib dicatat sebagai GitHub Issue**:
1. Buat Issue baru menggunakan template **Kendala pengerjaan** (`.github/ISSUE_TEMPLATE/kendala.md`).
2. Uraikan masalah, langkah reproduksi, bukti tangkapan layar/log error, serta upaya perbaikan yang telah dicoba.
3. Cantumkan tautan commit atau Pull Request penyelesaian sebelum menutup Issue tersebut.
