import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/responsive_layout.dart';

class CashierPosScreen extends StatefulWidget {
  const CashierPosScreen({super.key});

  @override
  State<CashierPosScreen> createState() => _CashierPosScreenState();
}

class _CashierPosScreenState extends State<CashierPosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchCategories();
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cashController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _showReceiptDialog(BuildContext context, CartProvider cart, String invoiceNum) {
    final auth = context.read<AuthProvider>();
    final store = auth.store;
    final cashier = auth.user;
    final items = cart.itemsList;
    final subtotal = cart.subtotal;
    final discount = cart.discount;
    final total = cart.finalTotal;
    final cash = cart.cashReceived;
    final change = cart.changeAmount;
    final method = cart.paymentMethod;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 8),
            Text('Transaksi Berhasil!'),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  store?.storeName ?? 'WARUNG MADURA',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  store?.address ?? 'Sleman, D.I. Yogyakarta',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nota: $invoiceNum', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    Text('Kasir: ${cashier?.name ?? "Kasir"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const Divider(height: 16),
                ...items.map(
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${i.product.productName} (x${i.quantity})',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatRupiah(i.subtotal),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 12)),
                    Text(CurrencyFormatter.formatRupiah(subtotal), style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (discount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diskon:', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                      Text('- ${CurrencyFormatter.formatRupiah(discount)}', style: const TextStyle(fontSize: 12, color: AppColors.danger)),
                    ],
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(
                      CurrencyFormatter.formatRupiah(total),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                if (method == 'cash') ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uang Diterima:', style: TextStyle(fontSize: 12)),
                      Text(CurrencyFormatter.formatRupiah(cash), style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kembalian:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(
                        CurrencyFormatter.formatRupiah(change),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  Text('Metode: ${method.toUpperCase()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
                const Divider(height: 20),
                const Text(
                  'Terima kasih atas kunjungan Anda!\nBarang yang sudah dibeli tidak dapat ditukar.',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.print),
            label: const Text('Cetak Nota'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nota struk siap dicetak ke printer kasir.')),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              cart.clearCart();
              _cashController.clear();
              _discountController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Transaksi Baru'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, CartProvider cart) async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih barang terlebih dahulu.')),
      );
      return;
    }

    if (cart.paymentMethod == 'cash' && !cart.isPaymentSufficient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uang yang diterima kurang dari total belanja.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final result = await cart.submitSale();

    if (!context.mounted) return;

    if (result != null) {
      final invoice = result['invoice_number']?.toString() ??
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // Refresh data produk agar stok yang berkurang langsung ter-update di layar POS
      context.read<ProductProvider>().fetchProducts();

      _showReceiptDialog(context, cart, invoice);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.errorMessage ?? 'Gagal memproses transaksi kasir.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildCartPanel(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nota Kasir (${cart.totalQuantity} item)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (!cart.isEmpty)
                TextButton(
                  onPressed: () {
                    cart.clearCart();
                    _cashController.clear();
                  },
                  child: const Text('Reset', style: TextStyle(color: AppColors.danger)),
                ),
            ],
          ),
          const Divider(height: 12),

          // Items List
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text(
                      'Pilih produk di katalog\nuntuk transaksi kasir',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: cart.itemsList.length,
                    separatorBuilder: (_, __) => const Divider(height: 10),
                    itemBuilder: (context, index) {
                      final item = cart.itemsList[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  CurrencyFormatter.formatRupiah(item.product.sellingPrice),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: () => cart.decrementItem(item.product.id),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(4),
                                onPressed: () => cart.incrementItem(item.product.id),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.formatRupiah(item.subtotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Divider(height: 16),

          // Subtotal & Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(color: Colors.grey)),
              Text(
                CurrencyFormatter.formatRupiah(cart.subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Bayar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.formatRupiah(cart.finalTotal),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment method selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Tunai', style: TextStyle(fontSize: 12)),
                  selected: cart.paymentMethod == 'cash',
                  onSelected: (val) {
                    if (val) cart.setPaymentMethod('cash');
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ChoiceChip(
                  label: const Text('QRIS', style: TextStyle(fontSize: 12)),
                  selected: cart.paymentMethod == 'qris',
                  onSelected: (val) {
                    if (val) cart.setPaymentMethod('qris');
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Transfer', style: TextStyle(fontSize: 12)),
                  selected: cart.paymentMethod == 'transfer',
                  onSelected: (val) {
                    if (val) cart.setPaymentMethod('transfer');
                  },
                ),
              ),
            ],
          ),

          if (cart.paymentMethod == 'cash') ...[
            const SizedBox(height: 10),
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Uang Diterima (Rp)',
                isDense: true,
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              onChanged: (val) {
                final amount = double.tryParse(val.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
                cart.setCashReceived(amount);
              },
            ),
            const SizedBox(height: 6),
            // Tombol cepat uang tunai
            Wrap(
              spacing: 6,
              children: [
                ActionChip(
                  label: const Text('Uang Pas', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _cashController.text = cart.finalTotal.toInt().toString();
                    cart.setCashReceived(cart.finalTotal);
                  },
                ),
                ActionChip(
                  label: const Text('20.000', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _cashController.text = '20000';
                    cart.setCashReceived(20000);
                  },
                ),
                ActionChip(
                  label: const Text('50.000', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _cashController.text = '50000';
                    cart.setCashReceived(50000);
                  },
                ),
                ActionChip(
                  label: const Text('100.000', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _cashController.text = '100000';
                    cart.setCashReceived(100000);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  CurrencyFormatter.formatRupiah(cart.changeAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Button Bayar
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: cart.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.payment),
              label: Text(
                cart.isSubmitting ? 'Memproses Transaksi...' : 'Bayar & Cetak Nota',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: (cart.isEmpty || cart.isSubmitting)
                  ? null
                  : () => _processPayment(context, cart),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final products = productProv.products.where((p) => p.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kasir POS (Point of Sale)'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (!isDesktop)
            IconButton(
              icon: Badge(
                label: Text('${cart.totalQuantity}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildCartPanel(context, cart),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Product Catalog
          Expanded(
            flex: isDesktop ? 6 : 10,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => productProv.searchProducts(val),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama barang atau scan barcode...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                productProv.searchProducts('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),

                // Category list
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: const Text('Semua'),
                          selected: _selectedCategory == null,
                          onSelected: (_) {
                            setState(() => _selectedCategory = null);
                            productProv.filterByCategory(null);
                          },
                        ),
                      ),
                      ...productProv.categories.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(c.categoryName),
                            selected: _selectedCategory == c.id,
                            onSelected: (_) {
                              setState(() => _selectedCategory = c.id);
                              productProv.filterByCategory(c.id);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Products Grid
                Expanded(
                  child: productProv.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : products.isEmpty
                          ? const Center(child: Text('Barang tidak ditemukan'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isDesktop ? 4 : 2,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final p = products[index];
                                final inCart = cart.items.containsKey(p.id);

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: inCart ? AppColors.primary : Colors.grey.shade200,
                                      width: inCart ? 2 : 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => cart.addItem(p),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.productName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Stok: ${p.stock} ${p.unit}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: p.isLowStock ? AppColors.danger : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                CurrencyFormatter.formatRupiah(p.sellingPrice),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.add, color: Colors.white, size: 16),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // Right: Cart & Payment Panel (Desktop)
          if (isDesktop)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16, bottom: 16),
                child: _buildCartPanel(context, cart),
              ),
            ),
        ],
      ),
    );
  }
}
