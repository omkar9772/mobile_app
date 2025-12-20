class Race {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String address;
  final String? gpsLocation;
  final String? managementContact;
  final int trackLength;
  final String trackLengthUnit;
  final String status;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Race({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.address,
    this.gpsLocation,
    this.managementContact,
    required this.trackLength,
    this.trackLengthUnit = 'meters',
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      address: json['address']?.toString() ?? '',
      gpsLocation: json['gps_location']?.toString(),
      managementContact: json['management_contact']?.toString(),
      trackLength: json['track_length'] ?? 200,
      trackLengthUnit: json['track_length_unit']?.toString() ?? 'meters',
      status: json['status']?.toString() ?? 'scheduled',
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'address': address,
      'gps_location': gpsLocation,
      'management_contact': managementContact,
      'track_length': trackLength,
      'track_length_unit': trackLengthUnit,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String getLocation() {
    return address;
  }

  String getTrackLength() {
    return '$trackLength $trackLengthUnit';
  }

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class RaceDay {
  final String id;
  final String raceId;
  final int dayNumber;
  final DateTime raceDate;
  final String? daySubtitle;
  final String status;
  final int totalParticipants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RaceDay({
    required this.id,
    required this.raceId,
    required this.dayNumber,
    required this.raceDate,
    this.daySubtitle,
    required this.status,
    this.totalParticipants = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory RaceDay.fromJson(Map<String, dynamic> json) {
    return RaceDay(
      id: json['id'],
      raceId: json['race_id'],
      dayNumber: json['day_number'],
      raceDate: DateTime.parse(json['race_date']),
      daySubtitle: json['day_subtitle'],
      status: json['status'],
      totalParticipants: json['total_participants'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'race_id': raceId,
      'day_number': dayNumber,
      'race_date': raceDate.toIso8601String(),
      'day_subtitle': daySubtitle,
      'status': status,
      'total_participants': totalParticipants,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class RaceResult {
  final String id;
  final String raceDayId;
  final String? bull1Id;
  final String? bull2Id;
  final String? owner1Id;
  final String? owner2Id;
  final int position;
  final int timeMilliseconds;
  final bool isDisqualified;
  final String? disqualificationReason;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Populated data
  final Map<String, dynamic>? bull1;
  final Map<String, dynamic>? bull2;
  final Map<String, dynamic>? owner1;
  final Map<String, dynamic>? owner2;

  RaceResult({
    required this.id,
    required this.raceDayId,
    this.bull1Id,
    this.bull2Id,
    this.owner1Id,
    this.owner2Id,
    required this.position,
    required this.timeMilliseconds,
    this.isDisqualified = false,
    this.disqualificationReason,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.bull1,
    this.bull2,
    this.owner1,
    this.owner2,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      id: json['id'],
      raceDayId: json['race_day_id'],
      bull1Id: json['bull1_id'],
      bull2Id: json['bull2_id'],
      owner1Id: json['owner1_id'],
      owner2Id: json['owner2_id'],
      position: json['position'],
      timeMilliseconds: json['time_milliseconds'],
      isDisqualified: json['is_disqualified'] ?? false,
      disqualificationReason: json['disqualification_reason'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      bull1: json['bull1'],
      bull2: json['bull2'],
      owner1: json['owner1'],
      owner2: json['owner2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'race_day_id': raceDayId,
      'bull1_id': bull1Id,
      'bull2_id': bull2Id,
      'owner1_id': owner1Id,
      'owner2_id': owner2Id,
      'position': position,
      'time_milliseconds': timeMilliseconds,
      'is_disqualified': isDisqualified,
      'disqualification_reason': disqualificationReason,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String getFormattedTime() {
    double seconds = timeMilliseconds / 1000;
    return '${seconds.toStringAsFixed(2)}s';
  }

  String? get bull1PhotoUrl {
    if (bull1 != null && bull1!['photo_url'] != null) {
      return bull1!['photo_url'];
    }
    return null;
  }

  String? get bull2PhotoUrl {
    if (bull2 != null && bull2!['photo_url'] != null) {
      return bull2!['photo_url'];
    }
    return null;
  }

  String get bull1Name {
    return bull1?['name'] ?? 'Unknown';
  }

  String get bull2Name {
    return bull2?['name'] ?? 'Unknown';
  }

  String get owner1Name {
    return owner1?['full_name'] ?? 'Unknown';
  }

  String get owner2Name {
    return owner2?['full_name'] ?? 'Unknown';
  }
}
