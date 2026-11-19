import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  String _selectedPeriod = 'month'; // 'today', 'week', 'month', 'year'
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    final reportRes = await ApiService.get(
      '${ApiEndpoints.financialReport}?period=$_selectedPeriod',
    );
    final expenseRes = await ApiService.get(ApiEndpoints.expenses);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (reportRes.success && reportRes.data != null) {
          _reportData = reportRes.data as Map<String, dynamic>;
        }
        if (expenseRes.success && expenseRes.data != null) {
          _expenses = expenseRes.data is List ? expenseRes.data : [];
        }
      });
    }
  }

  void _showAddExpenseDialog() {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Catat Beban Pengeluaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Keterangan *',
                hint: 'contoh: Beli Kantong Plastik / Listrik',
                controller: descController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Nominal Biaya (Rp) *',
                hint: 'contoh: 25000',
                controller: amountController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                  final num = double.tryParse(val.replaceAll('.', '').replaceAll(',', ''));
                  if (num == null || num <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              final amount = double.parse(
                amountController.text.replaceAll('.', '').replaceAll(',', '').trim(),
              );

              final res = await ApiService.post(
                ApiEndpoints.expenses,
                body: {
                  'description': descController.text.trim(),
                  'amount': amount,
                },
              );

              if (mounted) {
                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengeluaran berhasil dicatat.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadReport();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.message),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final revenue = (_reportData?['revenue'] as num?)?.toDouble() ?? 0.0;
    final cogs = (_reportData?['cogs'] as num?)?.toDouble() ?? 0.0;
    final grossProfit = (_reportData?['gross_profit'] as num?)?.toDouble() ?? 0.0;
    final grossMargin = (_reportData?['gross_margin_percentage'] as num?)?.toDouble() ?? 0.0;
    final expenses = (_reportData?['expenses'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (_reportData?['net_profit'] as num?)?.toDouble() ?? 0.0;
    final txCount = (_reportData?['transactions'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Keuangan & Laba'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Laporan',
            onPressed: _loadReport,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Catat Pengeluaran'),
        onPressed: _showAddExpenseDialog,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data laporan keuangan...')
          : RefreshIndicator(
              onRefresh: _loadReport,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Periode Filter Bar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodBtn('Hari Ini', 'today'),
                          _buildPeriodBtn('7 Hari', 'week'),
                          _buildPeriodBtn('Bulan Ini', 'month'),
                          _buildPeriodBtn('Tahun Ini', 'year'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Laba Bersih Utama (Highlight)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: netProfit >= 0
                              ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)]
                              : [const Color(0xFF991B1B), const Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                'Laba Bersih Operasional (${_getPeriodLabel()})',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                netProfit >= 0
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.formatRupiah(netProfit),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Dihitung dari: Laba Kotor - Beban Pengeluaran Warung',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid Metrik Finansial
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Total Omset (Penjualan)',
                            amount: revenue,
                            subtitle: '$txCount transaksi berhasil',
                            icon: Icons.storefront_outlined,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'HPP / Modal Barang',
                            amount: cogs,
                            subtitle: 'Snapshot modal produk',
                            icon: Icons.inventory_2_outlined,
                            iconColor: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Laba Kotor (Gross Profit)',
                            amount: grossProfit,
                            subtitle: 'Margin: $grossMargin%',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Beban Operasional',
                            amount: expenses,
                            subtitle: 'Listrik, sewa, plastik, dll',
                            icon: Icons.receipt_long_outlined,
                            iconColor: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Section Rincian Pengeluaran
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Catatan Pengeluaran Operasional',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_expenses.length} Catatan',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_expenses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada pengeluaran yang dicatat pada periode ini.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _expenses.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final item = _expenses[idx];
                          final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
                          final desc = item['description'] ?? '-';
                          final date = item['expense_date'] ?? '';

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_downward_rounded,
                                    color: AppColors.danger,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        desc,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        date,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '- ${CurrencyFormatter.formatRupiah(amount)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Hari Ini';
      case 'week':
        return '7 Hari Terakhir';
      case 'month':
        return 'Bulan Ini';
      case 'year':
        return 'Tahun Ini';
      default:
        return 'Periode Terpilih';
    }
  }

  Widget _buildPeriodBtn(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (_selectedPeriod != value) {
            setState(() => _selectedPeriod = value);
            _loadReport();
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatRupiah(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
