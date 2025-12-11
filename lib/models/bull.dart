class Bull {
  final String id;
  final String name;
  final String? breed;
  final int? age;
  final String? color;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final String? ownerName;
  final String? ownerVillage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bull({
    required this.id,
    required this.name,
    this.breed,
    this.age,
    this.color,
    this.description,
    this.imageUrl,
    required this.ownerId,
    this.ownerName,
    this.ownerVillage,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bull.fromJson(Map<String, dynamic> json) {
    return Bull(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      age: json['age'],
      color: json['color'],
      description: json['description'],
      imageUrl: json['image_url'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      ownerVillage: json['owner_village'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'age': age,
      'color': color,
      'description': description,
      'image_url': imageUrl,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_village': ownerVillage,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
