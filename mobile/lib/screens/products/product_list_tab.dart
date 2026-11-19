import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import 'add_edit_product_screen.dart';

class ProductListTab extends StatefulWidget {
  const ProductListTab({super.key});

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.fetchCategories();
      provider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBarcodeLookupDialog() {
    final barcodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cari Barcode Produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masukkan kode barcode (contoh: 8996001414018 untuk Le Minerale):',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: barcodeController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Kode Barcode EAN-13',
                prefixIcon: Icon(Icons.qr_code_scanner),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = barcodeController.text.trim();
              if (code.isEmpty) return;
              Navigator.pop(ctx);

              final provider = context.read<ProductProvider>();
              final found = await provider.findByBarcode(code);

              if (!mounted) return;

              if (found != null) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(found.productName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Barcode: ${found.barcode ?? "-"}'),
                        const SizedBox(height: 4),
                        Text(
                            'Kategori: ${found.categoryName ?? "Umum"} • Satuan: ${found.unit}'),
                        const SizedBox(height: 8),
                        Text(
                          'Harga Jual: ${CurrencyFormatter.format(found.sellingPrice)}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text('Stok Tersedia: ${found.stock} ${found.unit}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Produk dengan barcode "$code" tidak ditemukan atau tidak aktif.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isOwner = authProvider.isOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Katalog & Stok Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Cari via Barcode',
            onPressed: _showBarcodeLookupDialog,
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditProductScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Produk'),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => productProvider.search(val),
              decoration: InputDecoration(
                hintText: 'Cari nama produk atau barcode...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          productProvider.search('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Category Chips Bar
          if (productProvider.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: productProvider.categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected =
                        productProvider.selectedCategoryId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: const Text('Semua'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        onSelected: (_) =>
                            productProvider.filterByCategory(null),
                      ),
                    );
                  }

                  final cat = productProvider.categories[index - 1];
                  final isSelected =
                      productProvider.selectedCategoryId == cat.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat.categoryName),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      onSelected: (_) =>
                          productProvider.filterByCategory(cat.id),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // List Produk
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await productProvider.fetchCategories();
                await productProvider.fetchProducts();
              },
              child: productProvider.isLoading &&
                      productProvider.products.isEmpty
                  ? const LoadingIndicator(message: 'Memuat katalog produk...')
                  : productProvider.products.isEmpty
                      ? EmptyState(
                          title: 'Tidak Ada Produk Ditemukan',
                          message: productProvider.searchQuery.isNotEmpty
                              ? 'Tidak ada produk yang cocok dengan "${productProvider.searchQuery}"'
                              : 'Katalog toko belum memiliki produk pada kategori ini.',
                          icon: Icons.inventory_2_outlined,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: productProvider.products.length,
                          itemBuilder: (context, index) {
                            final product = productProvider.products[index];
                            return ProductCard(
                              product: product,
                              isOwner: isOwner,
                              onEdit: isOwner
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditProductScreen(
                                              product: product),
                                        ),
                                      );
                                    }
                                  : null,
                              onDelete: isOwner
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Nonaktifkan Produk?'),
                                          content: Text(
                                              'Produk "${product.productName}" akan dinonaktifkan dari katalog aktif.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                await productProvider
                                                    .deleteProduct(product.id);
                                              },
                                              child: const Text('Nonaktifkan',
                                                  style: TextStyle(
                                                      color: AppColors.danger)),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  : null,
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
