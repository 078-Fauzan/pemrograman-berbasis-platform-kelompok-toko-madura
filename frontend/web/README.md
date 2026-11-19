# Frontend Web Dashboard — UMKMate

Bagian antarmuka web untuk sistem manajemen toko kelontong UMKMate.

---

## 🎯 Tujuan Modul
Menyediakan portal berbasis web bagi pemilik toko (*Owner*) untuk mengakses laporan keuangan komprehensif, ekspor data, dan analitik performa toko dari browser desktop.

---

## 🛠️ Teknologi yang Digunakan
- **Framework:** Svelte / SvelteKit (atau HTML5, CSS3, JavaScript modern)
- **Komunikasi Data:** REST API via Fetch / Axios
- **Autentikasi:** Bearer Token JWT yang tersimpan pada `sessionStorage` / `localStorage`

---

## 🚀 Cara Menjalankan (Pengembangan)
1. Buka folder `frontend/web`:
   ```bash
   cd frontend/web
   ```
2. Pasang dependensi jika menggunakan node-based package:
   ```bash
   npm install
   ```
3. Jalankan development server:
   ```bash
   npm run dev
   ```
4. Akses melalui browser pada alamat yang tertera (biasanya `http://localhost:5173`).
