class Bull {
  final String id;
  final String name;
  final String? breed;
  final int? birthYear;
  final String? color;
  final String? description;
  final String? photoUrl;
  final String? registrationNumber;
  final String? ownerName; // For list view compatibility
  final String? ownerAddress; // For list view compatibility
  final BullOwner? owner; // Detailed owner info for detail view
  final BullStatistics? statistics;

  Bull({
    required this.id,
    required this.name,
    this.breed,
    this.birthYear,
    this.color,
    this.description,
    this.photoUrl,
    this.registrationNumber,
    this.ownerName,
    this.ownerAddress,
    this.owner,
    this.statistics,
  });

  factory Bull.fromJson(Map<String, dynamic> json) {
    return Bull(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
      birthYear: json['birth_year'],
      color: json['color'],
      description: json['description'],
      photoUrl: json['photo_url'],
      registrationNumber: json['registration_number'],
      ownerName: json['owner_name'],
      ownerAddress: json['owner_address'],
      owner: json['owner'] != null
          ? BullOwner.fromJson(json['owner'])
          : null,
      statistics: json['statistics'] != null
          ? BullStatistics.fromJson(json['statistics'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'birth_year': birthYear,
      'color': color,
      'description': description,
      'photo_url': photoUrl,
      'registration_number': registrationNumber,
      'owner_name': ownerName,
      'owner_address': ownerAddress,
      'owner': owner?.toJson(),
      'statistics': statistics?.toJson(),
    };
  }

  // Helper methods
  String get displayAge {
    if (birthYear == null) return 'Unknown';
    final currentYear = DateTime.now().year;
    final age = currentYear - birthYear!;
    return '$age years';
  }
}

class BullStatistics {
  final int totalRaces;
  final int firstPlaceWins;
  final int? secondPlaceWins;
  final int? thirdPlaceWins;
  final int? bestTimeMilliseconds;
  final String? bestTimeFormatted;
  final int? avgTimeMilliseconds;
  final String? avgTimeFormatted;

  BullStatistics({
    required this.totalRaces,
    required this.firstPlaceWins,
    this.secondPlaceWins,
    this.thirdPlaceWins,
    this.bestTimeMilliseconds,
    this.bestTimeFormatted,
    this.avgTimeMilliseconds,
    this.avgTimeFormatted,
  });

  factory BullStatistics.fromJson(Map<String, dynamic> json) {
    return BullStatistics(
      totalRaces: json['total_races'] ?? 0,
      firstPlaceWins: json['first_place_wins'] ?? 0,
      secondPlaceWins: json['second_place_wins'],
      thirdPlaceWins: json['third_place_wins'],
      bestTimeMilliseconds: json['best_time_milliseconds'],
      bestTimeFormatted: json['best_time_formatted'],
      avgTimeMilliseconds: json['avg_time_milliseconds'],
      avgTimeFormatted: json['avg_time_formatted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_races': totalRaces,
      'first_place_wins': firstPlaceWins,
      'second_place_wins': secondPlaceWins,
      'third_place_wins': thirdPlaceWins,
      'best_time_milliseconds': bestTimeMilliseconds,
      'best_time_formatted': bestTimeFormatted,
      'avg_time_milliseconds': avgTimeMilliseconds,
      'avg_time_formatted': avgTimeFormatted,
    };
  }

  double get winRate {
    if (totalRaces == 0) return 0.0;
    return (firstPlaceWins / totalRaces) * 100;
  }
}

class BullOwner {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? photoUrl;

  BullOwner({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.photoUrl,
  });

  factory BullOwner.fromJson(Map<String, dynamic> json) {
    return BullOwner(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'photo_url': photoUrl,
    };
  }
}
