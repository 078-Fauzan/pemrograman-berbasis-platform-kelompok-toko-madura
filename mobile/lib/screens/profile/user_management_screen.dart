import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final response = await ApiService.get(ApiEndpoints.users);
    if (response.success && response.data != null) {
      final list = response.data as List;
      _users = list.map((item) => UserModel.fromJson(item)).toList();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleUserStatus(UserModel user, bool newStatus) async {
    final response = await ApiService.patch(
      ApiEndpoints.userStatus(user.id),
      body: {'is_active': newStatus},
    );

    if (response.success) {
      _fetchUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status kasir ${user.name} berhasil diubah menjadi ${newStatus ? "Aktif" : "Nonaktif"}.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showAddCashierDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController(text: 'Password123!');
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Akun Kasir',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Nama Lengkap Kasir *',
                    hint: 'contoh: Ahmad Subarjo',
                    controller: nameController,
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Email Kasir *',
                    hint: 'contoh: ahmad@umkmate.com',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Nomor WhatsApp / HP',
                    hint: 'contoh: 081298765432',
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Kata Sandi Awal *',
                    hint: 'Minimal 6 karakter',
                    controller: passwordController,
                    validator: (val) =>
                        val == null || val.length < 6 ? 'Min. 6 karakter' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      final response = await ApiService.post(
                        ApiEndpoints.users,
                        body: {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'password': passwordController.text,
                        },
                      );

                      if (!mounted) return;
                      navigator.pop();

                      if (response.success) {
                        _fetchUsers();
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Akun kasir berhasil dibuat.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
              child: const Text('Buat Akun'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Kasir & Staf'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddCashierDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Tambah Kasir'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        child: _isLoading
            ? const LoadingIndicator(message: 'Memuat data staf toko...')
            : _users.isEmpty
                ? const EmptyState(
                    title: 'Belum Ada Akun Staf',
                    message: 'Tambahkan akun kasir untuk melayani penjualan toko.',
                    icon: Icons.people_outline,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final u = _users[index];
                      final isOwner = u.isOwner;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isOwner
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceVariant,
                              child: Icon(
                                isOwner
                                    ? Icons.admin_panel_settings
                                    : Icons.person_outline,
                                color: isOwner
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          u.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isOwner
                                              ? AppColors.primaryContainer
                                              : AppColors.surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isOwner ? 'OWNER' : 'KASIR',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isOwner
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    u.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (u.phone != null && u.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      'HP: ${u.phone}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (!isOwner) ...[
                              const SizedBox(width: 8),
                              Switch(
                                value: u.isActive,
                                activeColor: AppColors.primary,
                                onChanged: (newVal) =>
                                    _toggleUserStatus(u, newVal),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
