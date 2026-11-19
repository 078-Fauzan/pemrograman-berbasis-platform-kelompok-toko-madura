class StoreModel {
  final int id;
  final String storeName;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String? address;

  StoreModel({
    required this.id,
    required this.storeName,
    this.ownerName,
    this.email,
    this.phone,
    this.address,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      storeName: json['store_name'] ?? 'Toko Saya',
      ownerName: json['owner_name'],
      email: json['email'] ?? json['store_email'],
      phone: json['phone'] ?? json['store_phone'],
      address: json['address'] ?? json['store_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'owner_name': ownerName,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
