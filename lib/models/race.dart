class Race {
  final String id;
  final String name;
  final String? description;
  final DateTime raceDate;
  final String address;
  final int trackLengthMeters;
  final String status;
  final int totalParticipants;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RaceResult>? results;

  Race({
    required this.id,
    required this.name,
    this.description,
    required this.raceDate,
    required this.address,
    required this.trackLengthMeters,
    required this.status,
    required this.totalParticipants,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.results,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      raceDate: DateTime.parse(json['race_date']),
      address: json['address'],
      trackLengthMeters: json['track_length_meters'] ?? 200,
      status: json['status'],
      totalParticipants: json['total_participants'] ?? 0,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      results: json['results'] != null
          ? (json['results'] as List)
              .map((r) => RaceResult.fromJson(r))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'race_date': raceDate.toIso8601String(),
      'address': address,
      'track_length_meters': trackLengthMeters,
      'status': status,
      'total_participants': totalParticipants,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'results': results?.map((r) => r.toJson()).toList(),
    };
  }

  String getLocation() {
    return address;
  }

  String getTrackLength() {
    return '$trackLengthMeters m';
  }

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isScheduled => status.toLowerCase() == 'scheduled';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class RaceResult {
  final String id;
  final String raceId;
  final String bullId;
  final String? bullName;
  final String? ownerName;
  final int position;
  final int? timeMilliseconds;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  RaceResult({
    required this.id,
    required this.raceId,
    required this.bullId,
    this.bullName,
    this.ownerName,
    required this.position,
    this.timeMilliseconds,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RaceResult.fromJson(Map<String, dynamic> json) {
    return RaceResult(
      id: json['id'],
      raceId: json['race_id'],
      bullId: json['bull_id'],
      bullName: json['bull_name'],
      ownerName: json['owner_name'],
      position: json['position'],
      timeMilliseconds: json['time_milliseconds'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'race_id': raceId,
      'bull_id': bullId,
      'bull_name': bullName,
      'owner_name': ownerName,
      'position': position,
      'time_milliseconds': timeMilliseconds,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getFormattedTime() {
    if (timeMilliseconds == null) return '-';
    double seconds = timeMilliseconds! / 1000;
    return '${seconds.toStringAsFixed(2)}s';
  }
}
