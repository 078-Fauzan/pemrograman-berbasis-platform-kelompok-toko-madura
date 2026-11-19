class UserModel {
  final int id;
  final int storeId;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String role; // 'admin', 'owner', 'cashier', atau 'customer'
  final bool isActive;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    required this.isActive,
    this.createdAt,
  });

  /// Role checks
  bool get isAdmin => role == 'admin' || role == 'owner';
  bool get isOwner => isAdmin; // Alias kompatibilitas
  bool get isCashier => role == 'cashier';
  bool get isCustomer => role == 'customer';

  String get roleDisplayName {
    if (isAdmin) return 'Administrator / Pemilik';
    if (isCashier) return 'Kasir Toko';
    if (isCustomer) return 'Pembeli / Pelanggan';
    return role;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeId: json['store_id'] is int
          ? json['store_id']
          : int.parse(json['store_id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? 'customer',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }
}
