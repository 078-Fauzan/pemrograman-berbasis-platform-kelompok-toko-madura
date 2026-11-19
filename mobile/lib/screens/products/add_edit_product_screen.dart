import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  bool get isEditing => product != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;

  int? _selectedCategoryId;
  String _selectedUnit = 'Pcs';
  bool _isActive = true;

  final List<String> _units = [
    'Pcs',
    'Bungkus',
    'Botol',
    'Renceng',
    'Dus',
    'Kg',
    'Liter',
    'Kaleng',
    'Kotak',
    'Batang',
    'Strip',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.productName ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _sellingPriceController =
        TextEditingController(text: p?.sellingPrice.toInt().toString() ?? '');
    _costPriceController = TextEditingController(
        text: p?.costPrice != null ? p!.costPrice!.toInt().toString() : '');
    _stockController =
        TextEditingController(text: p?.stock.toString() ?? '0');
    _minStockController =
        TextEditingController(text: p?.minimumStock.toString() ?? '5');

    _selectedCategoryId = p?.categoryId;
    if (p != null && _units.contains(p.unit)) {
      _selectedUnit = p.unit;
    }
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProductProvider>();
    final sellingPrice = double.tryParse(_sellingPriceController.text) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 0;
    final minStock = int.tryParse(_minStockController.text) ?? 5;

    bool success = false;
    if (widget.isEditing) {
      success = await provider.updateProduct(
        id: widget.product!.id,
        productName: _nameController.text,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        barcode: _barcodeController.text,
        categoryId: _selectedCategoryId,
        unit: _selectedUnit,
        minimumStock: minStock,
        isActive: _isActive,
      );
    } else {
      success = await provider.addProduct(
        productName: _nameController.text,
        sellingPrice: sellingPrice,
        costPrice: costPrice,
        barcode: _barcodeController.text,
        categoryId: _selectedCategoryId,
        unit: _selectedUnit,
        stock: stock,
        minimumStock: minStock,
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Data produk berhasil diperbarui.'
              : 'Produk baru berhasil ditambahkan.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      final err = provider.errorMessage ?? 'Gagal menyimpan produk.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.categories;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Data Produk' : 'Tambah Produk Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                CustomTextField(
                  label: 'Nama Produk *',
                  hint: 'contoh: Beras Ramos Super 5 Kg',
                  controller: _nameController,
                  prefixIcon: Icons.shopping_bag_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama produk wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Barcode
                CustomTextField(
                  label: 'Kode Barcode (Opsional)',
                  hint: 'contoh: 8991001100012',
                  controller: _barcodeController,
                  prefixIcon: Icons.qr_code_outlined,
                ),
                const SizedBox(height: 14),

                // Dropdown Kategori
                const Text(
                  'Kategori Produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined,
                        size: 20, color: AppColors.textMuted),
                    hintText: 'Pilih Kategori',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tanpa Kategori / Umum'),
                    ),
                    ...categories.map((c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.categoryName),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                ),
                const SizedBox(height: 14),

                // Satuan
                const Text(
                  'Satuan Produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.scale_outlined,
                        size: 20, color: AppColors.textMuted),
                  ),
                  items: _units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedUnit = val);
                  },
                ),
                const SizedBox(height: 14),

                // Harga Jual & Harga Modal
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Harga Jual (Rp) *',
                        hint: '0',
                        controller: _sellingPriceController,
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Wajib diisi';
                          }
                          if (double.tryParse(val) == null) {
                            return 'Nominal angka';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        label: 'Harga Modal (Rp)',
                        hint: '0',
                        controller: _costPriceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stok & Stok Minimum
                Row(
                  children: [
                    if (!widget.isEditing)
                      Expanded(
                        child: CustomTextField(
                          label: 'Stok Awal',
                          hint: '0',
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    if (!widget.isEditing) const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        label: 'Batas Stok Min.',
                        hint: '5',
                        controller: _minStockController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                if (widget.isEditing) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status Produk Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                CustomButton(
                  text: widget.isEditing ? 'Simpan Perubahan' : 'Tambahkan Produk',
                  isLoading: productProvider.isLoading,
                  onPressed: _handleSave,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
