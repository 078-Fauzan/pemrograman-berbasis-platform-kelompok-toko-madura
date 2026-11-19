import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../main_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  final int initialTab; // 0: Pembeli, 1: Toko Baru (Admin)

  const RegisterScreen({super.key, this.initialTab = 0});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _customerFormKey = GlobalKey<FormState>();
  final _adminFormKey = GlobalKey<FormState>();

  // Controllers Customer
  final _custNameController = TextEditingController();
  final _custEmailController = TextEditingController();
  final _custPhoneController = TextEditingController();
  final _custPasswordController = TextEditingController();
  final _custAddressController = TextEditingController();

  // Controllers Admin / Toko
  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _storeAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _custNameController.dispose();
    _custEmailController.dispose();
    _custPhoneController.dispose();
    _custPasswordController.dispose();
    _custAddressController.dispose();
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _adminEmailController.dispose();
    _adminPhoneController.dispose();
    _adminPasswordController.dispose();
    _storeAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleCustomerRegister() async {
    if (!_customerFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.registerCustomer(
      name: _custNameController.text,
      email: _custEmailController.text,
      phone: _custPhoneController.text,
      password: _custPasswordController.text,
      address: _custAddressController.text.isNotEmpty
          ? _custAddressController.text
          : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun pembeli Anda berhasil dibuat. Selamat berbelanja!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal mendaftar akun pembeli'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleStoreRegister() async {
    if (!_adminFormKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      storeName: _storeNameController.text,
      ownerName: _ownerNameController.text,
      email: _adminEmailController.text,
      phone: _adminPhoneController.text,
      password: _adminPasswordController.text,
      address: _storeAddressController.text.isNotEmpty
          ? _storeAddressController.text
          : null,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Toko & Akun Admin Anda berhasil didaftarkan.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal mendaftarkan toko'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pendaftaran Akun'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.shopping_bag_outlined),
              text: 'Pengunjung / Pembeli',
            ),
            Tab(
              icon: Icon(Icons.storefront_outlined),
              text: 'Toko Baru (Admin)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: FORM PEMBELI
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _customerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Sebagai Pembeli',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pesan sembako, makanan & kebutuhan harian dari Warung Madura dengan mudah.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Nama Lengkap',
                    hint: 'Contoh: Budi Santoso',
                    controller: _custNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Nomor WhatsApp / Telepon',
                    hint: 'Contoh: 081234567890',
                    controller: _custPhoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => v == null || v.length < 8 ? 'Nomor telepon tidak valid' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Email',
                    hint: 'Contoh: budi@gmail.com',
                    controller: _custEmailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Kata Sandi',
                    hint: 'Minimal 6 karakter',
                    controller: _custPasswordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) => v == null || v.length < 6 ? 'Kata sandi minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Alamat Rumah / Pengiriman (Opsional)',
                    hint: 'Contoh: Jl. Kaliurang KM 5 Gang Pandega Marta No. 8',
                    controller: _custAddressController,
                    prefixIcon: Icons.home_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Daftar Sebagai Pembeli',
                    isLoading: auth.isLoading,
                    onPressed: _handleCustomerRegister,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // TAB 2: FORM TOKO BARU (ADMIN)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _adminFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buka Toko Baru (Owner/Admin)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kelola stok barang, transaksi kasir POS, dan pantau laba penjualan bisnis Anda.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Nama Warung / Toko Kelontong',
                    hint: 'Contoh: Warung Madura Berkah',
                    controller: _storeNameController,
                    prefixIcon: Icons.store_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Nama toko wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Nama Pemilik Toko (Admin)',
                    hint: 'Contoh: Fauzan',
                    controller: _ownerNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v == null || v.isEmpty ? 'Nama pemilik wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Email Toko',
                    hint: 'Contoh: berkah@umkmate.com',
                    controller: _adminEmailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Nomor Telepon Toko',
                    hint: 'Contoh: 081234567890',
                    controller: _adminPhoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => v == null || v.length < 8 ? 'Nomor telepon minimal 8 digit' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Kata Sandi Admin',
                    hint: 'Minimal 6 karakter',
                    controller: _adminPasswordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) => v == null || v.length < 6 ? 'Kata sandi minimal 6 karakter' : null,
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'Alamat Toko (Opsional)',
                    hint: 'Contoh: Jl. Kaliurang KM 5.5 No. 12, Sleman',
                    controller: _storeAddressController,
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Daftarkan Toko Sekarang',
                    isLoading: auth.isLoading,
                    onPressed: _handleStoreRegister,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
