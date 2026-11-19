import 'package:flutter/foundation.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';
import '../models/store_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  StoreModel? _store;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  StoreModel? get store => _store;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isOwner => _user?.isOwner ?? false;
  bool get isCashier => _user?.isCashier ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;

  /// Inisialisasi: Cek sesi token yang tersimpan di memori perangkat
  Future<void> checkAuthSession() async {
    _setLoading(true);
    try {
      final hasToken = await StorageService.hasValidSession();
      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        _setLoading(false);
        return;
      }

      // Ambil cache lokal terlebih dahulu untuk kecepatan render
      _user = await StorageService.getUser();
      _store = await StorageService.getStore();

      // Sinkronisasi data terkini ke endpoint /auth/me
      final response = await ApiService.get(ApiEndpoints.me);
      if (response.success && response.data != null) {
        final userData = response.data['user'];
        final storeData = response.data['store'];

        _user = UserModel.fromJson(userData);
        _store = StoreModel.fromJson(storeData);
        _status = AuthStatus.authenticated;

        // Simpan pembaruan ke storage
        final token = await StorageService.getToken();
        if (token != null) {
          await StorageService.saveSession(
            token: token,
            user: _user!,
            store: _store!,
          );
        }
      } else {
        // Jika token ditolak oleh backend (misal kedaluwarsa atau dinonaktifkan)
        await StorageService.clearSession();
        _user = null;
        _store = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  /// Login Pengguna (Admin, Kasir, atau Pengunjung/Pembeli)
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await ApiService.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
      withAuth: false,
    );

    _setLoading(false);

    if (response.success && response.data != null) {
      final token = response.data['token'];
      final userData = response.data['user'];
      final storeData = response.data['store'];

      _user = UserModel.fromJson(userData);
      _store = StoreModel.fromJson(storeData);
      _status = AuthStatus.authenticated;

      await StorageService.saveSession(
        token: token,
        user: _user!,
        store: _store!,
      );

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Registrasi Toko Baru & Owner/Admin Baru
  Future<bool> register({
    required String storeName,
    required String ownerName,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await ApiService.post(
      ApiEndpoints.register,
      body: {
        'store_name': storeName.trim(),
        'owner_name': ownerName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'address': address?.trim(),
      },
      withAuth: false,
    );

    _setLoading(false);

    if (response.success && response.data != null) {
      final token = response.data['token'];
      final userData = response.data['user'];
      final storeData = response.data['store'];

      _user = UserModel.fromJson(userData);
      _store = StoreModel.fromJson(storeData);
      _status = AuthStatus.authenticated;

      await StorageService.saveSession(
        token: token,
        user: _user!,
        store: _store!,
      );

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Registrasi Akun Pengunjung / Pembeli Baru (Customer)
  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await ApiService.post(
      ApiEndpoints.registerCustomer,
      body: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
      },
      withAuth: false,
    );

    _setLoading(false);

    if (response.success && response.data != null) {
      final token = response.data['token'];
      final userData = response.data['user'];
      final storeData = response.data['store'];

      _user = UserModel.fromJson(userData);
      _store = StoreModel.fromJson(storeData);
      _status = AuthStatus.authenticated;

      await StorageService.saveSession(
        token: token,
        user: _user!,
        store: _store!,
      );

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Update Profil Pengguna & Profil Toko (Owner / Admin)
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? storeName,
    String? address,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await ApiService.put(
      ApiEndpoints.profile,
      body: {
        if (name != null) 'name': name.trim(),
        if (phone != null) 'phone': phone.trim(),
        if (storeName != null) 'store_name': storeName.trim(),
        if (address != null) 'address': address.trim(),
      },
    );

    _setLoading(false);

    if (response.success && response.data != null) {
      final userData = response.data['user'];
      final storeData = response.data['store'];

      _user = UserModel.fromJson(userData);
      _store = StoreModel.fromJson(storeData);

      final token = await StorageService.getToken();
      if (token != null) {
        await StorageService.saveSession(
          token: token,
          user: _user!,
          store: _store!,
        );
      }

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Lupa Password (Permintaan Reset Token)
  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    final response = await ApiService.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email.trim()},
      withAuth: false,
    );

    _setLoading(false);

    if (response.success) {
      return response.message;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return null;
    }
  }

  /// Logout
  Future<void> logout() async {
    await StorageService.clearSession();
    _user = null;
    _store = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
