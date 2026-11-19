import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/responsive_layout.dart';

class CustomerCartTab extends StatefulWidget {
  final VoidCallback onNavigateToOrders;
  final VoidCallback onNavigateToShop;

  const CustomerCartTab({
    super.key,
    required this.onNavigateToOrders,
    required this.onNavigateToShop,
  });

  @override
  State<CustomerCartTab> createState() => _CustomerCartTabState();
}

class _CustomerCartTabState extends State<CustomerCartTab> {
  String _orderType = 'takeaway'; // 'takeaway' atau 'delivery'
  String _paymentMethod = 'cash'; // 'cash' atau 'qris'
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.user?.address != null && auth.user!.address!.isNotEmpty) {
      _addressController.text = auth.user!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();

    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang belanja Anda masih kosong.')),
      );
      return;
    }

    if (_orderType == 'delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan alamat pengiriman.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final items = cart.itemsList.map((item) => item.toOrderItemJson()).toList();

    final success = await orderProv.createOrder(
      orderType: _orderType,
      deliveryAddress: _orderType == 'delivery'
          ? _addressController.text.trim()
          : 'Ambil di Toko',
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      items: items,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      cart.clearCart();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Text('Pesanan Terkirim!'),
            ],
          ),
          content: const Text(
            'Pesanan Anda telah diterima oleh Warung Madura. Kasir akan segera menyiapkan pesanan Anda.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onNavigateToOrders();
              },
              child: const Text('Lihat Pesanan Saya'),
            ),
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProv.errorMessage ?? 'Gagal membuat pesanan.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Keranjang Belanja'),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keranjang Masih Kosong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yuk pilih barang belanjaan sembako, minuman, atau snack favoritmu di etalase warung!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.storefront),
                  label: const Text('Mulai Belanja Sekarang'),
                  onPressed: widget.onNavigateToShop,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final content = SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Items List Section
          Text(
            'Daftar Barang (${cart.totalQuantity} item)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.itemsList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cartItem = cart.itemsList[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cartItem.product.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.formatRupiah(cartItem.product.sellingPrice),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quantity Control
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, size: 22),
                          onPressed: () => cart.decrementItem(cartItem.product.id),
                          color: AppColors.textSecondary,
                        ),
                        Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 22),
                          onPressed: () => cart.incrementItem(cartItem.product.id),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Order Options (Pengambilan & Pengiriman)
          const Text(
            'Metode Pengambilan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _orderType = 'takeaway'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _orderType == 'takeaway'
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: _orderType == 'takeaway'
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: _orderType == 'takeaway' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.storefront_rounded, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text(
                          'Ambil di Toko',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Siap diambil mandiri',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _orderType = 'delivery'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _orderType == 'delivery'
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      border: Border.all(
                        color: _orderType == 'delivery'
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: _orderType == 'delivery' ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.delivery_dining, color: AppColors.primary),
                        SizedBox(height: 6),
                        Text(
                          'Antar ke Rumah',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Diantar kurir warung',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Address field (if delivery)
          if (_orderType == 'delivery') ...[
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap rumah / kos...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Payment Method
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Bayar di Tempat (Tunai / COD)'),
                  subtitle: const Text('Bayar saat barang diterima atau diambil'),
                  value: 'cash',
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('QRIS Warung Madura'),
                  subtitle: const Text('Scan QRIS saat pengambilan atau pengantaran'),
                  value: 'qris',
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Catatan Pesanan
          const Text(
            'Catatan untuk Penjual (Opsional)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Contoh: Tolong pilihkan yang dingin, bungkus terpisah...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ringkasan Biaya
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal Belanja', style: TextStyle(color: Colors.grey)),
                    Text(
                      CurrencyFormatter.formatRupiah(cart.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ongkos Kirim', style: TextStyle(color: Colors.grey)),
                    Text(
                      _orderType == 'delivery' ? 'Gratis (Warung Madura)' : 'Rp 0',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(cart.subtotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submitOrder,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Kirim Pesanan Sekarang',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete_sweep, color: AppColors.danger, size: 20),
            label: const Text('Kosongkan', style: TextStyle(color: AppColors.danger)),
            onPressed: () {
              cart.clearCart();
            },
          ),
        ],
      ),
      body: content,
    );
  }
}
