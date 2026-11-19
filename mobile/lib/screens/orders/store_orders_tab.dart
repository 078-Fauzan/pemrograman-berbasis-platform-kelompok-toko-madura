import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/responsive_layout.dart';

class StoreOrdersTab extends StatefulWidget {
  const StoreOrdersTab({super.key});

  @override
  State<StoreOrdersTab> createState() => _StoreOrdersTabState();
}

class _StoreOrdersTabState extends State<StoreOrdersTab> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.indigo;
      case 'ready':
        return Colors.teal;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return Colors.grey;
    }
  }

  void _showOrderActionModal(OrderModel order) async {
    final detail = await context.read<OrderProvider>().fetchOrderDetail(order.id);
    if (!mounted || detail == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        detail.orderNumber,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(detail.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          detail.statusDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(detail.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pemesan: ${detail.customerName} (${detail.customerPhone})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    'Metode: ${detail.orderType == "delivery" ? "Diantar ke Rumah" : "Ambil di Toko"} • Bayar: ${detail.paymentMethod.toUpperCase()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (detail.deliveryAddress != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Alamat: ${detail.deliveryAddress}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                  if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(
                        'Catatan: "${detail.notes}"',
                        style: const TextStyle(fontSize: 13, color: Colors.brown),
                      ),
                    ),
                  ],
                  const Divider(height: 28),

                  const Text(
                    'Daftar Barang',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (detail.items != null)
                    ...detail.items!.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} (x${item.quantity})',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatRupiah(item.subtotal),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Transaksi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(detail.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons berdasarkan status
                  const Text(
                    'Ubah Status Pesanan:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (detail.status == 'pending') ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Konfirmasi Pesanan'),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<OrderProvider>().updateOrderStatus(detail.id, 'confirmed');
                          },
                        ),
                      ],
                      if (detail.status == 'confirmed') ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          icon: const Icon(Icons.hourglass_top, size: 16),
                          label: const Text('Mulai Disiapkan'),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<OrderProvider>().updateOrderStatus(detail.id, 'processing');
                          },
                        ),
                      ],
                      if (detail.status == 'processing') ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Tandai Siap'),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<OrderProvider>().updateOrderStatus(detail.id, 'ready');
                          },
                        ),
                      ],
                      if (detail.status == 'ready') ...[
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text('Selesai (Sudah Diambil / Diantar)'),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<OrderProvider>().updateOrderStatus(detail.id, 'completed');
                          },
                        ),
                      ],
                      if (detail.status != 'completed' && detail.status != 'cancelled') ...[
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Batalkan Pesanan'),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<OrderProvider>().updateOrderStatus(detail.id, 'cancelled');
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final statusFilters = [
      {'label': 'Semua', 'val': null},
      {'label': 'Pending', 'val': 'pending'},
      {'label': 'Terkonfirmasi', 'val': 'confirmed'},
      {'label': 'Disiapkan', 'val': 'processing'},
      {'label': 'Siap', 'val': 'ready'},
      {'label': 'Selesai', 'val': 'completed'},
    ];

    final filteredOrders = _selectedStatus == null
        ? orderProv.orders
        : orderProv.orders.where((o) => o.status == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Online Masuk'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan',
            onPressed: () => orderProv.fetchOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter status horizontal
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 16,
              vertical: 10,
            ),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusFilters.map((sf) {
                  final isSelected = _selectedStatus == sf['val'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(sf['label'] as String),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedStatus = sf['val']);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => orderProv.fetchOrders(),
              child: orderProv.isLoading && orderProv.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak Ada Pesanan',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Pesanan baru dari pembeli akan muncul otomatis di sini.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 16,
                            vertical: 14,
                          ),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final statusColor = _getStatusColor(order.status);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: InkWell(
                                onTap: () => _showOrderActionModal(order),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            order.orderNumber,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              order.statusDisplay,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Pelanggan: ${order.customerName} (${order.customerPhone})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            order.orderType == 'delivery'
                                                ? Icons.delivery_dining
                                                : Icons.storefront,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            order.orderType == 'delivery'
                                                ? 'Diantar ke Rumah'
                                                : 'Ambil di Toko',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.payment, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            order.paymentMethod.toUpperCase(),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 18),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${order.totalItems} item barang',
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                          ),
                                          Text(
                                            CurrencyFormatter.formatRupiah(order.totalAmount),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppColors.primary,
                                            ),
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
          ),
        ],
      ),
    );
  }
}
