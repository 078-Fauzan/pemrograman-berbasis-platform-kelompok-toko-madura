# ALUR PROSES TRANSAKSI PENJUALAN (SALES TRANSACTION FLOW)
## KONSISTENSI ACID & ATURAN BISNIS KASIR

Dokumen ini menjelaskan secara rinci alur proses checkout kasir pada aplikasi **UMKMate**, mulai dari input di antarmuka ponsel hingga eksekusi query transaksi database MySQL yang mematuhi prinsip ACID.

---

## 1. Sequence Diagram Alur Checkout

```mermaid
sequenceDiagram
    autonumber
    actor Kasir as Kasir / Mobile App
    participant Mobile as Flutter (POS Provider)
    participant API as Express Router & Auth Guard
    participant Service as Sales Service (Business Logic)
    participant DB as MySQL Database (umkmate_db)

    Kasir->>Mobile: Tekan tombol "Proses Pembayaran"
    Note over Mobile: Siapkan payload JSON:<br/>{ customer_id, items: [{product_id, quantity}], discount, payment: {method, cash_received} }
    Mobile->>API: POST /api/v1/sales (Header: Authorization Bearer Token)
    
    API->>API: 1. Verifikasi JWT<br/>2. Ekstrak req.user.storeId & req.user.userId<br/>3. Validasi skema input (express-validator)
    
    API->>Service: createSale(storeId, userId, payload)
    
    Service->>DB: START TRANSACTION
    
    rect rgb(240, 248, 255)
        Note over Service, DB: PENGUNCIAN STOK (Pessimistic Locking)
        Service->>DB: SELECT id, product_name, cost_price, selling_price, stock, minimum_stock, is_active FROM products WHERE id IN (...) AND store_id = ? FOR UPDATE
        DB-->>Service: Return row data produk
    end
    
    alt Ada produk tidak valid atau bukan milik toko
        Service->>DB: ROLLBACK
        Service-->>API: Throw Error "Produk tidak ditemukan atau tidak aktif"
        API-->>Mobile: 400 Bad Request
    else Ada stok tidak mencukupi (stock < quantity)
        Service->>DB: ROLLBACK
        Service-->>API: Throw Error "Stok [Nama Produk] tidak mencukupi"
        API-->>Mobile: 400 Bad Request
    else Stok mencukupi & produk valid
        Note over Service: 1. Ambil harga jual & modal langsung dari DB<br/>2. Hitung subtotal = sum(selling_price * qty)<br/>3. Hitung total = subtotal - discount<br/>4. Hitung kembalian = cash_received - total<br/>5. Generate Invoice: INV-YYYYMMDD-XXXX
        
        Service->>DB: INSERT INTO sales (store_id, customer_id, cashier_id, invoice_number, subtotal, discount, total, status, sale_date)
        DB-->>Service: Return sale_id
        
        loop Setiap Item Belanja
            Service->>DB: INSERT INTO sale_items (sale_id, product_id, quantity, selling_price, unit_cost, subtotal)
            Note over Service, DB: Snapshot unit_cost disimpan permanen
            
            Service->>DB: UPDATE products SET stock = stock - ? WHERE id = ?
            
            Service->>DB: INSERT INTO stock_movements (store_id, product_id, user_id, movement_type: 'sale', quantity, stock_before, stock_after, reference_type: 'sale', reference_id: sale_id)
            
            opt Jika stok_after <= minimum_stock
                Service->>DB: INSERT INTO notifications (store_id, title, message, type: 'stock_alert')
            end
        end
        
        Service->>DB: INSERT INTO payments (sale_id, received_by, payment_method, amount, cash_received, change_amount)
        
        Service->>DB: INSERT INTO activity_logs (store_id, user_id, activity: 'CREATE_SALE', description: 'Nota INV-...')
        
        Service->>DB: COMMIT
        DB-->>Service: Transaksi Berhasil
        
        Service-->>API: Return Data Lengkap Penjualan & Invoice
        API-->>Mobile: 201 Created + JSON Data Struk
        Mobile-->>Kasir: Tampilkan Dialog Sukses & Struk Digital
    end
```

---

## 2. Rincian Langkah & Pencegahan Masalah Bisnis

### A. Pencegahan Kecurangan Harga (Price Tampering)
- **Aturan:** Flutter **TIDAK** dipercaya untuk menentukan harga jual (`selling_price`) maupun harga modal (`cost_price`).
- **Implementasi:** Backend selalu membaca harga terbaru dari tabel `products` saat transaksi diproses. Jika di sisi client harga diubah secara ilegal, perhitungan backend tetap menggunakan harga resmi database.

### B. Pencegahan Race Condition & Stok Negatif
- **Masalah:** Jika dua kasir melakukan checkout produk terakhir yang tersisa 1 buah secara bersamaan, tanpa penguncian stok kedua kasir bisa sama-sama berhasil sehingga stok menjadi `-1`.
- **Solusi:** Eksekusi `SELECT ... FOR UPDATE` di dalam `START TRANSACTION`. Transaksi kedua akan menunggu (lock) hingga transaksi pertama selesai dan melakukan commit/rollback. Ketika giliran transaksi kedua memeriksa stok, stok telah bernilai 0 dan backend langsung melempar pesan error bahwa stok habis.

### C. Snapshot HPP (Historical Cost Price Accuracy)
- **Aturan:** Harga modal produk bisa naik turun dari waktu ke waktu karena pembelian grosir baru.
- **Implementasi:** Kolom `sale_items.unit_cost` menyimpan snapshot harga modal pada detik transaksi terjadi. Dengan demikian, jika 2 bulan kemudian harga modal beras naik dari Rp 12.000 menjadi Rp 14.000, laporan laba kotor transaksi lama tidak akan berubah.

### D. Mekanisme Void / Pembatalan Transaksi
1. Hanya dapat dilakukan oleh pengguna ber-role `owner`.
2. Status penjualan diubah menjadi `status = 'voided'` (data tidak dihapus fisik).
3. Seluruh kuantitas barang yang ada di `sale_items` dikembalikan ke stok `products`:
   `UPDATE products SET stock = stock + quantity WHERE id = product_id`.
4. Pergerakan stok dicatat dengan `movement_type = 'void'`.
5. Tercatat di `activity_logs` dengan alasan pembatalan.
