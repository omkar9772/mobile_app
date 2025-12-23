class Owner {
  final String id;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String? email;
  final String? address;
  final int? bullCount;

  Owner({
    required this.id,
    required this.name,
    this.photoUrl,
    this.phone,
    this.email,
    this.address,
    this.bullCount,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      photoUrl: json['photo_url'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      bullCount: json['bull_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'phone': phone,
      'email': email,
      'address': address,
      'bull_count': bullCount,
    };
  }
}
