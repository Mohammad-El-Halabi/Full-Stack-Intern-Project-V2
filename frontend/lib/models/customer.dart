/// A store customer, matching the backend CustomerResponse.
class Customer {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Customer({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int?,
        name: json['name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
      );

  /// Body for create / update requests (matches CustomerRequest).
  Map<String, dynamic> toRequestJson() => {
        'name': name,
        'email': (email != null && email!.trim().isEmpty) ? null : email,
        'phone': phone,
        'address': address,
      };
}
