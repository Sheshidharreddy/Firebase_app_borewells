enum VehicleType {
  truck,
  van,
  car,
  motorcycle,
}

enum VehicleStatus {
  available,
  inUse,
  maintenance,
  outOfService,
}

class VehicleModel {
  final String id;
  final String name;
  final String licensePlate;
  final VehicleType type;
  final VehicleStatus status;
  final String? driverId;
  final String? driverName;
  final String? model;
  final String? year;
  final String? color;
  final double? capacity;
  final double? hours;     // Total operating hours
  final double? km;        // Total kilometers/mileage
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.type,
    required this.status,
    this.driverId,
    this.driverName,
    this.model,
    this.year,
    this.color,
    this.capacity,
    this.hours,
    this.km,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from Firestore document
  factory VehicleModel.fromMap(Map<String, dynamic> map, String id) {
    return VehicleModel(
      id: id,
      name: map['name'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      type: VehicleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => VehicleType.truck,
      ),
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VehicleStatus.available,
      ),
      driverId: map['driverId'],
      driverName: map['driverName'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      capacity: map['capacity']?.toDouble(),
      hours: map['hours']?.toDouble(),
      km: map['km']?.toDouble(),
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt']?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt']?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'licensePlate': licensePlate,
      'type': type.name,
      'status': status.name,
      'driverId': driverId,
      'driverName': driverName,
      'model': model,
      'year': year,
      'color': color,
      'capacity': capacity,
      'hours': hours,
      'km': km,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copy with updated fields
  VehicleModel copyWith({
    String? id,
    String? name,
    String? licensePlate,
    VehicleType? type,
    VehicleStatus? status,
    String? driverId,
    String? driverName,
    String? model,
    String? year,
    String? color,
    double? capacity,
    double? hours,
    double? km,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      capacity: capacity ?? this.capacity,
      hours: hours ?? this.hours,
      km: km ?? this.km,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper getters
  bool get isAvailable => status == VehicleStatus.available;
  bool get hasDriver => driverId != null && driverId!.isNotEmpty;
  
  String get typeDisplayName {
    switch (type) {
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.van:
        return 'Van';
      case VehicleType.car:
        return 'Car';
      case VehicleType.motorcycle:
        return 'Motorcycle';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.inUse:
        return 'In Use';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.outOfService:
        return 'Out of Service';
    }
  }
}
