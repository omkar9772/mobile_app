class MarketplaceListing {
  final String id;
  final String name;
  final String ownerName;
  final String ownerMobile;
  final String? location;
  final double price;
  final String? imageUrl;
  final String? description;
  final String status;
  final DateTime? createdAt;

  MarketplaceListing({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerMobile,
    this.location,
    required this.price,
    this.imageUrl,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'],
      name: json['name'],
      ownerName: json['owner_name'],
      ownerMobile: json['owner_mobile'],
      location: json['location'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      description: json['description'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Format price as Indian Rupees
  String get formattedPrice {
    return '₹${price.toStringAsFixed(0)}';
  }

  // Format price in lakhs/crores for large amounts
  String get formattedPriceShort {
    if (price >= 10000000) {
      // Crore
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      // Lakh
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }
}
