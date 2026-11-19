import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Memuat kategori produk
  Future<void> fetchCategories() async {
    final response = await ApiService.get(ApiEndpoints.categories);
    if (response.success && response.data != null) {
      final list = response.data as List;
      _categories = list.map((item) => CategoryModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  /// Memuat daftar produk toko dengan filter aktif
  Future<void> fetchProducts({int? categoryId, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (categoryId != null) _selectedCategoryId = categoryId;
    if (search != null) _searchQuery = search;

    try {
      final queryParams = <String>[];
      if (_selectedCategoryId != null) {
        queryParams.add('category_id=$_selectedCategoryId');
      }
      if (_searchQuery.isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(_searchQuery)}');
      }

      String url = ApiEndpoints.products;
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await ApiService.get(url);
      if (response.success && response.data != null) {
        final list = response.data as List;
        _products = list.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat produk: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter kategori
  void filterByCategory(int? categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null; // Toggle unselect
    } else {
      _selectedCategoryId = categoryId;
    }
    fetchProducts();
  }

  /// Pencarian produk
  void search(String query) {
    _searchQuery = query.trim();
    fetchProducts();
  }

  /// Alias searchProducts
  void searchProducts(String query) => search(query);

  /// Cari produk berdasarkan kode barcode
  Future<ProductModel?> findByBarcode(String barcode) async {
    final response = await ApiService.get(ApiEndpoints.productBarcode(barcode));
    if (response.success && response.data != null) {
      return ProductModel.fromJson(response.data);
    }
    return null;
  }

  /// Tambah produk baru (Owner only)
  Future<bool> addProduct({
    required String productName,
    required double sellingPrice,
    double costPrice = 0,
    String? barcode,
    int? categoryId,
    String unit = 'Pcs',
    int stock = 0,
    int minimumStock = 5,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.post(
      ApiEndpoints.products,
      body: {
        'product_name': productName.trim(),
        'selling_price': sellingPrice,
        'cost_price': costPrice,
        'barcode': barcode?.trim().isEmpty == true ? null : barcode?.trim(),
        'category_id': categoryId,
        'unit': unit,
        'stock': stock,
        'minimum_stock': minimumStock,
      },
    );

    _isLoading = false;

    if (response.success) {
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Edit produk (Owner only)
  Future<bool> updateProduct({
    required int id,
    required String productName,
    required double sellingPrice,
    double? costPrice,
    String? barcode,
    int? categoryId,
    String? unit,
    int? minimumStock,
    bool? isActive,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ApiService.put(
      ApiEndpoints.productDetail(id),
      body: {
        'product_name': productName.trim(),
        'selling_price': sellingPrice,
        if (costPrice != null) 'cost_price': costPrice,
        'barcode': barcode?.trim().isEmpty == true ? null : barcode?.trim(),
        'category_id': categoryId,
        if (unit != null) 'unit': unit,
        if (minimumStock != null) 'minimum_stock': minimumStock,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      },
    );

    _isLoading = false;

    if (response.success) {
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Soft Delete produk (Owner only)
  Future<bool> deleteProduct(int id) async {
    final response = await ApiService.delete(ApiEndpoints.productDetail(id));
    if (response.success) {
      await fetchProducts();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Tambah kategori baru (Owner only)
  Future<bool> addCategory(String categoryName) async {
    final response = await ApiService.post(
      ApiEndpoints.categories,
      body: {'category_name': categoryName.trim()},
    );

    if (response.success) {
      await fetchCategories();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  /// Ubah nama kategori (Owner only)
  Future<bool> updateCategory(int id, String categoryName) async {
    final response = await ApiService.put(
      ApiEndpoints.categoryDetail(id),
      body: {'category_name': categoryName.trim()},
    );

    if (response.success) {
      await fetchCategories();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  /// Hapus kategori (Owner only)
  Future<bool> deleteCategory(int id) async {
    final response = await ApiService.delete(ApiEndpoints.categoryDetail(id));
    if (response.success) {
      await fetchCategories();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }
}
