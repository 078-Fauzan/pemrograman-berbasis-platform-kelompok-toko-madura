# ARSITEKTUR SISTEM UMKMATE

Aplikasi **UMKMate** dirancang dengan arsitektur **3-Tier Client-Server Architecture** yang modular, terisolasi, dan aman.

---

## 1. Diagram Arsitektur Tingkat Tinggi

```
+-----------------------------------------------------------+
|                   FLUTTER MOBILE CLIENT                   |
|                   (Android Application)                   |
|                                                           |
|  - UI Layer (Material Design 3, Emerald/Mint Theme)      |
|  - State Management (Provider: Auth, Product, Cart, etc.) |
|  - Data Layer / Repositories (HTTP / Dio Client)          |
|  - Secure Storage (JWT Token Storage)                    |
|  - Hardware Access (Camera via mobile_scanner)            |
+-----------------------------------------------------------+
                              |
                              | HTTPS / HTTP REST API
                              | Payload: JSON
                              | Header: Authorization: Bearer <JWT>
                              v
+-----------------------------------------------------------+
|               NODE.JS + EXPRESS.JS BACKEND                |
|                                                           |
|  - Routing Layer (/api/v1/...)                            |
|  - Middleware Pipeline:                                   |
|      * CORS & Security Headers (Helmet)                   |
|      * Request Logger (Morgan)                            |
|      * Authentication Guard (verifyJwt)                   |
|      * Role Authorization Guard (requireRole: owner/cash) |
|      * Data Isolation Guard (inject store_id from token)  |
|      * Input Validation (express-validator)               |
|  - Controller Layer (Request/Response Handling)           |
|  - Service Layer (Business Logic & Transactions)          |
|  - Centralized Error Handler (Formatted JSON Responses)   |
+-----------------------------------------------------------+
                              |
                              | MySQL2 / Connection Pool
                              | Parameterized SQL Queries
                              | ACID Transactions (COMMIT / ROLLBACK)
                              v
+-----------------------------------------------------------+
|                      MYSQL DATABASE                       |
|                       (umkmate_db)                        |
|                                                           |
|  - Multi-tenant Isolation (store_id in every table)       |
|  - Foreign Key Constraints & Cascades                     |
|  - Composite Indexes for High Performance                 |
|  - Pessimistic Row Locking (SELECT ... FOR UPDATE)        |
+-----------------------------------------------------------+
```

---

## 2. Prinsip Isolasi Data Toko (Multi-Tenancy)

Setiap warung atau toko memiliki data yang terisolasi sepenuhnya. Keamanan isolasi data dijamin dengan aturan ketat:

1. **Token Claims:** Payload JWT hanya berisi:
   ```json
   {
     "userId": 1,
     "storeId": 1,
     "role": "owner"
   }
   ```
2. **Backend Enforcement:**
   - Backend **tidak pernah** mempercayai `store_id` yang dikirim dari form body atau parameter URL klien.
   - Middleware autentikasi mengekstrak `storeId` dari token JWT yang telah diverifikasi dan menyematkannya ke objek `req.user`.
   - Setiap query `SELECT`, `INSERT`, `UPDATE`, `DELETE` wajib memfilter `WHERE store_id = req.user.storeId`.
   - Hal ini menjamin kasir atau pemilik toko A tidak akan pernah bisa mengakses atau memodifikasi data milik toko B.

---

## 3. Strategi Keamanan (Security Hardening)

1. **Hashing Password:**
   - Semua password disimpan dalam bentuk hash menggunakan `bcrypt` dengan salt minimum 10 rounds.
   - Password asli tidak pernah disimpan dalam database maupun dicatat dalam log sistem.
2. **Koneksi Database:**
   - Menggunakan `mysql2/promise` dengan Connection Pool (`connectionLimit: 10`).
   - Mencegah SQL Injection dengan **Prepared Statements** dan parameterized queries (`?`).
3. **Penyimpanan Token di Mobile:**
   - Token disimpan di memori aman perangkat menggunakan `flutter_secure_storage` (Android Keystore).
4. **Validasi Request:**
   - Setiap payload request divalidasi menggunakan `express-validator` sebelum diteruskan ke layer service.
