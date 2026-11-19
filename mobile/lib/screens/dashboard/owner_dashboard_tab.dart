import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sales_chart_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_indicator.dart';
import '../notifications/notification_screen.dart';
import '../products/add_edit_product_screen.dart';
import '../products/category_management_screen.dart';
import '../pos/cashier_pos_screen.dart';

class OwnerDashboardTab extends StatefulWidget {
  final VoidCallback? onNavigateToProducts;
  final VoidCallback? onNavigateToPos;

  const OwnerDashboardTab({
    super.key,
    this.onNavigateToProducts,
    this.onNavigateToPos,
  });

  @override
  State<OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<OwnerDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashProvider = context.watch<DashboardProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final user = authProvider.user;
    final store = authProvider.store;
    final summary = dashProvider.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store?.storeName ?? 'Warung Madura',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Pemilik: ${user?.name ?? "Owner"}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notifProvider.unreadCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dashProvider.fetchDashboard();
          await notifProvider.fetchNotifications();
        },
        child: dashProvider.isLoading && summary.totalProducts == 0
            ? const LoadingIndicator(message: 'Memuat data analitik toko...')
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Peringatan Stok Menipis jika ada
                    if (summary.lowStockProducts > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Peringatan Stok Menipis',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Terdapat ${summary.lowStockProducts} produk dengan stok di bawah batas aman.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onNavigateToProducts,
                              child: const Text('Lihat'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Kartu Statistik Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Penjualan Hari Ini',
                            value: CurrencyFormatter.format(summary.salesToday),
                            icon: Icons.payments_outlined,
                            iconColor: AppColors.primary,
                            subtitle: '${summary.transactionsToday} Transaksi',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Total Produk Aktif',
                            value: '${summary.totalProducts}',
                            icon: Icons.inventory_2_outlined,
                            iconColor: AppColors.info,
                            subtitle: '${summary.lowStockProducts} Stok Menipis',
                            onTap: widget.onNavigateToProducts,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Pengeluaran Hari Ini',
                            value: CurrencyFormatter.format(summary.expensesToday),
                            icon: Icons.receipt_long_outlined,
                            iconColor: AppColors.warning,
                            subtitle: 'Buku Kas Operasional',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Status Toko',
                            value: 'Buka 24 Jam',
                            icon: Icons.store_outlined,
                            iconColor: AppColors.success,
                            subtitle: 'Warung Madura',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Shortcut Aksi Cepat
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionBtn(
                            icon: Icons.add_box_outlined,
                            label: 'Tambah Produk',
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AddEditProductScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionBtn(
                            icon: Icons.category_outlined,
                            label: 'Kategori',
                            color: AppColors.info,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CategoryManagementScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionBtn(
                            icon: Icons.point_of_sale_outlined,
                            label: 'Buka Kasir',
                            color: AppColors.secondary,
                            onTap: () {
                              if (widget.onNavigateToPos != null) {
                                widget.onNavigateToPos!();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CashierPosScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Grafik Penjualan (fl_chart)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tren Penjualan (7 Hari Terakhir)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Icon(Icons.show_chart,
                                  size: 20, color: AppColors.primary),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Data historis penjualan bersih yang telah diselesaikan.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 180,
                            child: dashProvider.chartData.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Belum ada transaksi dalam 7 hari terakhir',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted),
                                    ),
                                  )
                                : _buildSalesLineChart(dashProvider.chartData),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Top Produk Terlaris
                    if (dashProvider.bestSelling.isNotEmpty) ...[
                      const Text(
                        'Produk Paling Laris',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dashProvider.bestSelling.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: AppColors.divider),
                          itemBuilder: (context, index) {
                            final item = dashProvider.bestSelling[index];
                            final rank = index + 1;
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: rank == 1
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                child: Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: rank == 1
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              title: Text(
                                item['product_name'] ?? 'Produk',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Terjual: ${item['total_sold']} ${item['unit'] ?? "pcs"}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted),
                              ),
                              trailing: Text(
                                CurrencyFormatter.format(item['total_revenue']),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesLineChart(List<SalesChartPoint> points) {
    final spots = <FlSpot>[];
    double maxY = 10000;

    for (int i = 0; i < points.length; i++) {
      final amount = points[i].totalAmount;
      if (amount > maxY) maxY = amount;
      spots.add(FlSpot(i.toDouble(), amount));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 3 > 0 ? maxY / 3 : 10000,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < points.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      points[index].formattedDate,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}
