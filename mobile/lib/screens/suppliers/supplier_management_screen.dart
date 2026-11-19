import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() =>
      _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  List<dynamic> _suppliers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers({String? search}) async {
    setState(() => _isLoading = true);

    String url = ApiEndpoints.suppliers;
    if (search != null && search.isNotEmpty) {
      url += '?search=${Uri.encodeComponent(search)}';
    }

    final res = await ApiService.get(url);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null) {
          _suppliers = res.data is List ? res.data : [];
        }
      });
    }
  }

  void _showAddEditSupplierDialog({Map<String, dynamic>? supplier}) {
    final isEdit = supplier != null;
    final nameController = TextEditingController(text: supplier?['supplier_name']);
    final phoneController = TextEditingController(text: supplier?['phone']);
    final addressController = TextEditingController(text: supplier?['address']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Ubah Rekanan Pemasok' : 'Tambah Pemasok Baru',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Nama Pemasok / Distributor *',
                hint: 'contoh: Agen Sembako Barokah',
                controller: nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Nomor Telepon / Sales',
                hint: 'contoh: 081298765432',
                controller: phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: 'Alamat Gudang / Catatan',
                hint: 'contoh: Pasar Induk Blok C No. 12',
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
                'supplier_name': nameController.text.trim(),
                'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                'address': addressController.text.trim().isEmpty ? null : addressController.text.trim(),
              };

              final res = isEdit
                  ? await ApiService.put(ApiEndpoints.supplierDetail(supplier['id']), body: body)
                  : await ApiService.post(ApiEndpoints.suppliers, body: body);

              if (mounted) {
                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Pemasok berhasil diperbarui.' : 'Pemasok berhasil ditambahkan.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _fetchSuppliers();
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

  void _confirmDeleteSupplier(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Pemasok?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pemasok "${supplier['supplier_name']}"?',
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
              final res = await ApiService.delete(ApiEndpoints.supplierDetail(supplier['id']));

              if (mounted) {
                if (res.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data pemasok berhasil dihapus.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _fetchSuppliers();
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
        title: const Text('Pemasok & Pembelian Grosir'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Tambah Pemasok'),
        onPressed: () => _showAddEditSupplierDialog(),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari distributor / pemasok...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchSuppliers();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (val) => _fetchSuppliers(search: val.trim()),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Memuat data pemasok...')
                : RefreshIndicator(
                    onRefresh: () => _fetchSuppliers(search: _searchController.text.trim()),
                    child: _suppliers.isEmpty
                        ? const EmptyState(
                            title: 'Belum Ada Pemasok',
                            message: 'Tambahkan data pemasok & distributor grosir warung Anda di sini.',
                            icon: Icons.local_shipping_outlined,
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _suppliers.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (ctx, idx) {
                              final sup = _suppliers[idx] as Map<String, dynamic>;
                              final name = sup['supplier_name'] ?? '-';
                              final phone = sup['phone'] ?? '-';
                              final address = sup['address'] ?? 'Alamat belum diatur';

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
                                        color: AppColors.secondary.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.local_shipping_rounded,
                                        size: 22,
                                        color: AppColors.secondary,
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
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _showAddEditSupplierDialog(supplier: sup);
                                        } else if (val == 'delete') {
                                          _confirmDeleteSupplier(sup);
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
