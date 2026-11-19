import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';
import '../products/category_management_screen.dart';
import 'user_management_screen.dart';
import '../reports/financial_report_screen.dart';
import '../customers/customer_management_screen.dart';
import '../suppliers/supplier_management_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameController = TextEditingController(text: auth.user?.name);
    final phoneController = TextEditingController(text: auth.user?.phone);
    final storeNameController =
        TextEditingController(text: auth.store?.storeName);
    final addressController = TextEditingController(text: auth.store?.address);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profil & Toko',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Nama Lengkap',
                  controller: nameController,
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'Nomor WhatsApp / HP',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                if (auth.isOwner) ...[
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Nama Toko / Warung',
                    controller: storeNameController,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Alamat Toko',
                    controller: addressController,
                    maxLines: 2,
                  ),
                ],
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);

              final success = await auth.updateProfile(
                name: nameController.text,
                phone: phoneController.text,
                storeName: auth.isOwner ? storeNameController.text : null,
                address: auth.isOwner ? addressController.text : null,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Profil berhasil diperbarui.'
                        : (auth.errorMessage ?? 'Gagal memperbarui profil.')),
                    backgroundColor:
                        success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
            'Sesi aktif pada perangkat ini akan diakhiri. Anda perlu login kembali untuk mengakses data toko.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final store = auth.store;
    final isOwner = auth.isOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan & Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      isOwner
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user?.name ?? 'Nama Pengguna',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isOwner
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isOwner ? 'OWNER' : 'KASIR',
                                style: TextStyle(
                                  fontSize: 10,
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
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'HP: ${user.phone}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Store Info Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront_rounded,
                              size: 20, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Informasi Toko',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.primary),
                        onPressed: () => _showEditProfileDialog(context, auth),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.divider),
                  _buildStoreRow('Nama Toko', store?.storeName ?? '-'),
                  const SizedBox(height: 8),
                  _buildStoreRow('Pemilik', store?.ownerName ?? user?.name ?? '-'),
                  const SizedBox(height: 8),
                  _buildStoreRow('Telepon Toko', store?.phone ?? '-'),
                  const SizedBox(height: 8),
                  _buildStoreRow('Alamat', store?.address ?? 'Belum diisi'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu Manajemen Toko
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  if (isOwner) ...[
                    _buildMenuItem(
                      icon: Icons.people_outline,
                      title: 'Manajemen Akun Kasir',
                      subtitle: 'Tambah kasir, aktifkan atau nonaktifkan staf',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserManagementScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuItem(
                      icon: Icons.category_outlined,
                      title: 'Kategori Master Produk',
                      subtitle: 'Kelompok barang dagangan warung',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const CategoryManagementScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuItem(
                      icon: Icons.local_shipping_outlined,
                      title: 'Pemasok & Pembelian Grosir',
                      subtitle: 'Pendataan rekanan supplier & faktur kulakan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupplierManagementScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuItem(
                      icon: Icons.person_search_outlined,
                      title: 'Buku Data Pelanggan',
                      subtitle: 'Daftar pembeli tetap dan riwayat belanja',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerManagementScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Laporan Keuangan & Laba Kotor',
                      subtitle: 'Ringkasan omset, HPP, pengeluaran, dan margin laba',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FinancialReportScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Logout
            CustomButton(
              text: 'Keluar dari Akun',
              icon: Icons.logout,
              isOutlined: true,
              backgroundColor: AppColors.danger,
              textColor: AppColors.danger,
              onPressed: () => _showLogoutDialog(context, auth),
            ),

            const SizedBox(height: 16),
            const Text(
              'UMKMate v1.0.0 • Sistem Informasi Warung Madura',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const Text(': ',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
