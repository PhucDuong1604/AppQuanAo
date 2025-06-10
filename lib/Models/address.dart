// lib/models/address.dart
class Address {
  String street; // Thay đổi thành non-final để có thể chỉnh sửa nếu cần
  String district;
  String city;
  String name;
  String phone;
  bool isDefault;

  Address({
    required this.street,
    required this.district,
    required this.city,
    required this.name,
    required this.phone,
    this.isDefault = false,
  });

  // Constructor để tạo một bản sao có thể chỉnh sửa
  Address copyWith({
    String? street,
    String? district,
    String? city,
    String? name,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      street: street ?? this.street,
      district: district ?? this.district,
      city: city ?? this.city,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}