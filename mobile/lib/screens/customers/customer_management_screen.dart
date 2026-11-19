import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<dynamic> _customers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomers({String? search}) async {
    setState(() => _isLoading = true);

    String url = ApiEndpoints.customers;
    if (search != null && search.isNotEmpty) {
      url += '?search=${Uri.encodeComponent(search)}';
    }

    final res = await ApiService.get(url);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _customers = res.data is List ? res.data : [];
        }
      });
    }
  }

  void _showAddEditCustomerDialog({Map<String, dynamic>? customer}) {
    final isEdit = customer != null;
    final nameController = TextEditingController(text: customer?['customer_name']);
    final phoneController = TextEditingController(text: customer?['phone']);
    final addressController = TextEditingController(text: customer?['address']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Ubah Data Pelanggan' : 'Tambah Pelanggan Baru',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Nama Pelanggan *',
                hint: 'contoh: Bu Siti',
                controller: nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Nomor WhatsApp / HP',
                hint: 'contoh: 081234567890',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Alamat / Catatan Rumah',
                hint: 'contoh: RT 02 / RW 03 Rumah Pagar Biru',
                controller: addressController,
                maxLines: 2,
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

              final body = {
                'customer_name': nameController.text.trim(),
                'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                'address': addressController.text.trim().isEmpty ? null : addressController.text.trim(),
              };

              final res = isEdit
                  ? await ApiService.put(ApiEndpoints.customerDetail(customer['id']), body: body)
                  : await ApiService.post(ApiEndpoints.customers, body: body);

              if (mounted) {
                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Pelanggan berhasil diperbarui.' : 'Pelanggan berhasil ditambahkan.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _fetchCustomers();
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

  void _confirmDeleteCustomer(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pelanggan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data "${customer['customer_name']}"?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService.delete(ApiEndpoints.customerDetail(customer['id']));

              if (mounted) {
                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data pelanggan berhasil dihapus.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _fetchCustomers();
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buku Data Pelanggan'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan'),
        onPressed: () => _showAddEditCustomerDialog(),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau no. telepon...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchCustomers();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (val) => _fetchCustomers(search: val.trim()),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Memuat data pelanggan...')
                : RefreshIndicator(
                    onRefresh: () => _fetchCustomers(search: _searchController.text.trim()),
                    child: _customers.isEmpty
                        ? const EmptyState(
                            title: 'Belum Ada Pelanggan',
                            message: 'Catat pelanggan setia warung untuk melacak riwayat belanjanya.',
                            icon: Icons.people_alt_outlined,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _customers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (ctx, idx) {
                              final cust = _customers[idx] as Map<String, dynamic>;
                              final name = cust['customer_name'] ?? '-';
                              final phone = cust['phone'] ?? '-';
                              final address = cust['address'] ?? 'Alamat belum diatur';
                              final totalSpend = (cust['total_spend'] as num?)?.toDouble() ?? 0.0;
                              final totalOrders = (cust['total_orders'] as num?)?.toInt() ?? 0;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 22,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.phone, size: 12, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(
                                                phone,
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            address,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (totalOrders > 0) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Total Belanja: ${CurrencyFormatter.formatRupiah(totalSpend)} ($totalOrders kali)',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddEditCustomerDialog(customer: cust);
                                        } else if (val == 'delete') {
                                          _confirmDeleteCustomer(cust);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, size: 18),
                                              SizedBox(width: 8),
                                              Text('Ubah Data', style: TextStyle(fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                              SizedBox(width: 8),
                                              Text('Hapus', style: TextStyle(fontSize: 13, color: AppColors.danger)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
