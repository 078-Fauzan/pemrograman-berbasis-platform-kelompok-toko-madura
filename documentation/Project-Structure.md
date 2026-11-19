# STRUKTUR FOLDER PROYEK UMKMATE

Proyek diorganisir secara modular, memisahkan tanggung jawab antara lapisan data, logika bisnis, dan antarmuka pengguna secara bersih (Separation of Concerns).

```
toko_madura/
│
├── backend/                              # Backend Service (Node.js + Express)
│   ├── src/
│   │   ├── config/                       # Konfigurasi database & environment
│   │   │   ├── database.js               # MySQL2 connection pool setup
│   │   │   └── env.js                    # Validasi & eksport variabel environment
│   │   ├── controllers/                  # Handler request & response HTTP
│   │   │   ├── authController.js
│   │   │   ├── userController.js
│   │   │   ├── dashboardController.js
│   │   │   ├── productController.js
│   │   │   ├── categoryController.js
│   │   │   ├── stockController.js
│   │   │   ├── supplierController.js
│   │   │   ├── purchaseController.js
│   │   │   ├── salesController.js
│   │   │   ├── customerController.js
│   │   │   ├── expenseController.js
│   │   │   ├── reportController.js
│   │   │   ├── notificationController.js
│   │   │   └── activityController.js
│   │   ├── middleware/                   # Interceptor request HTTP
│   │   │   ├── authMiddleware.js         # Verifikasi token JWT & claims
│   │   │   ├── roleMiddleware.js         # Pengecekan otorisasi role (owner vs cashier)
│   │   │   ├── validateMiddleware.js     # Validasi skema input (express-validator)
│   │   │   └── errorHandler.js           # Penanganan error global terpusat
│   │   ├── routes/                       # Deklarasi endpoint REST API (/api/v1/...)
│   │   │   ├── authRoutes.js
│   │   │   ├── userRoutes.js
│   │   │   ├── dashboardRoutes.js
│   │   │   ├── productRoutes.js
│   │   │   ├── categoryRoutes.js
│   │   │   ├── stockRoutes.js
│   │   │   ├── supplierRoutes.js
│   │   │   ├── purchaseRoutes.js
│   │   │   ├── salesRoutes.js
│   │   │   ├── customerRoutes.js
│   │   │   ├── expenseRoutes.js
│   │   │   ├── reportRoutes.js
│   │   │   ├── notificationRoutes.js
│   │   │   ├── activityRoutes.js
│   │   │   └── index.js
│   │   ├── services/                     # Business logic & MySQL Transactions
│   │   │   ├── authService.js
│   │   │   ├── salesService.js           # ACID Checkout logic & stock locking
│   │   │   ├── purchaseService.js        # Restock logic & stock movement
│   │   │   ├── stockService.js           # Stock in, out, and movement logs
│   │   │   └── reportService.js          # Gross profit, net profit, aggregations
│   │   ├── validators/                   # Skema aturan validasi express-validator
│   │   │   ├── authValidator.js
│   │   │   ├── productValidator.js
│   │   │   ├── salesValidator.js
│   │   │   └── expenseValidator.js
│   │   ├── utils/                        # Helper functions & formatter
│   │   │   ├── responseHelper.js         # Format response JSON seragam
│   │   │   ├── invoiceGenerator.js       # Generator no faktur: INV-YYYYMMDD-XXXX
│   │   │   └── passwordHelper.js        # Bcrypt hash & compare
│   │   └── app.js                        # Inisialisasi Express & middleware pipeline
│   ├── .env.example
│   ├── package.json
│   └── server.js                         # Entry point server HTTP listener
│
├── mobile/                               # Mobile Application (Flutter Android)
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/                # URL API, storage keys, teks statis
│   │   │   │   ├── api_endpoints.dart
│   │   │   │   ├── app_colors.dart       # Emerald & Mint palette
│   │   │   │   └── app_constants.dart
│   │   │   ├── theme/                    # Material 3 Theme data & typography
│   │   │   │   └── app_theme.dart
│   │   │   ├── utils/                    # Format currency IDR, tanggal Indo
│   │   │   │   ├── currency_formatter.dart
│   │   │   │   └── date_formatter.dart
│   │   │   └── routing/                  # Route generator & role guard
│   │   │       └── app_routes.dart
│   │   ├── models/                       # Data class model & JSON serialization
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── cart_item_model.dart
│   │   │   ├── sale_model.dart
│   │   │   ├── customer_model.dart
│   │   │   ├── supplier_model.dart
│   │   │   ├── purchase_model.dart
│   │   │   ├── expense_model.dart
│   │   │   ├── dashboard_summary_model.dart
│   │   │   └── report_model.dart
│   │   ├── services/                     # HTTP client communication
│   │   │   ├── api_service.dart          # Base HTTP client with JWT interceptor
│   │   │   ├── auth_service.dart
│   │   │   ├── product_service.dart
│   │   │   ├── pos_service.dart
│   │   │   ├── inventory_service.dart
│   │   │   ├── report_service.dart
│   │   │   └── storage_service.dart      # FlutterSecureStorage wrapper
│   │   ├── providers/                    # State Management (Provider)
│   │   │   ├── auth_provider.dart        # Session state, login, user info
│   │   │   ├── product_provider.dart     # Catalog, stock list, filters
│   │   │   ├── cart_provider.dart        # POS cart, subtotal, discount, cash
│   │   │   ├── transaction_provider.dart # History, void, receipts
│   │   │   ├── customer_provider.dart
│   │   │   ├── supplier_provider.dart
│   │   │   ├── expense_provider.dart
│   │   │   ├── dashboard_provider.dart   # Daily metrics, fl_chart data
│   │   │   └── notification_provider.dart
│   │   ├── widgets/                      # Komponen UI modular re-usable
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── stat_card.dart
│   │   │   ├── product_card.dart
│   │   │   ├── receipt_dialog.dart
│   │   │   ├── barcode_scanner_modal.dart
│   │   │   └── loading_indicator.dart
│   │   ├── screens/                      # Layar antarmuka pengguna
│   │   │   ├── auth/                     # Splash, Onboarding, Login, Register, Forgot
│   │   │   ├── dashboard/                # Owner & Cashier Dashboards
│   │   │   ├── products/                 # Product List, Add, Edit, Categories
│   │   │   ├── inventory/                # Stock In, Stock Out, Stock Log
│   │   │   ├── pos/                      # POS Catalog, Cart, Checkout, Payment
│   │   │   ├── transactions/             # Sales History, Invoice Detail
│   │   │   ├── customers/                # Customer CRUD & History
│   │   │   ├── suppliers/                # Supplier CRUD & Purchases
│   │   │   ├── purchases/                # Add Purchase, Purchase History
│   │   │   ├── finance/                  # Expenses, Gross Profit, Financial Report
│   │   │   ├── users/                    # Cashier Management for Owner
│   │   │   └── profile/                  # Store profile & settings
│   │   └── main.dart                     # App entry point with MultiProvider setup
│   └── pubspec.yaml
│
├── database/                             # Basis Data MySQL
│   ├── umkmate_db.sql                    # Skrip DDL 16 tabel, FK, dan Indexes
│   └── seed.sql                          # Skrip DML data awal demo UMKM
│
├── documentation/                        # Dokumentasi Proyek
│   ├── Functional-Requirements.md
│   ├── Architecture.md
│   ├── ERD.md
│   ├── UseCase.md
│   ├── Sales-Transaction-Flow.md
│   ├── Project-Structure.md
│   ├── UI-UX-Design.md
│   ├── Dependencies.md
│   └── API-Documentation.md
│
└── README.md                             # Panduan Instalasi & Eksekusi Lengkap
```
