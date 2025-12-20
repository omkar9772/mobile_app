class UserBullSell {
  final String id;
  final String userId;
  final String name;
  final String? breed;
  final int? birthYear;
  final String? color;
  final String? description;
  final double price;
  final String imageUrl;
  final String? location;
  final String? ownerMobile;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime expiresAt;
  final int daysRemaining;

  UserBullSell({
    required this.id,
    required this.userId,
    required this.name,
    this.breed,
    this.birthYear,
    this.color,
    this.description,
    required this.price,
    required this.imageUrl,
    this.location,
    this.ownerMobile,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.expiresAt,
    required this.daysRemaining,
  });

  factory UserBullSell.fromJson(Map<String, dynamic> json) {
    return UserBullSell(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      breed: json['breed'],
      birthYear: json['birth_year'],
      color: json['color'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      location: json['location'],
      ownerMobile: json['owner_mobile'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expiresAt: DateTime.parse(json['expires_at']),
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'breed': breed,
      'birth_year': birthYear,
      'color': color,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'location': location,
      'owner_mobile': ownerMobile,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'days_remaining': daysRemaining,
    };
  }

  String get formattedPrice {
    return '₹${price.toStringAsFixed(0)}';
  }

  String get formattedPriceShort {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  String get displayAge {
    if (birthYear == null) return 'Unknown';
    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear!;
    return '$age years';
  }

  bool get isExpired => status == 'expired' || daysRemaining <= 0;
  bool get isSold => status == 'sold';
  bool get isAvailable => status == 'available' && !isExpired;
}

class UserBullSellList {
  final List<UserBullSell> bulls;
  final int total;
  final int activeCount;
  final int maxAllowed;

  UserBullSellList({
    required this.bulls,
    required this.total,
    required this.activeCount,
    required this.maxAllowed,
  });

  factory UserBullSellList.fromJson(Map<String, dynamic> json) {
    return UserBullSellList(
      bulls: (json['bulls'] as List)
          .map((bull) => UserBullSell.fromJson(bull))
          .toList(),
      total: json['total'],
      activeCount: json['active_count'],
      maxAllowed: json['max_allowed'],
    );
  }

  bool get canAddMore => activeCount < maxAllowed;
  int get remainingSlots => maxAllowed - activeCount;
}
