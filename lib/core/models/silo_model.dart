class SiloModel {
  final int? id;
  final int? farmId; // New: Reference to Farm
  final String? farmName; // New: To display in the UI
  final String name;
  final double capacity;
  final double currentQuantity;
  final String status;
  final String? observations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiloModel({
    this.id,
    this.farmId,
    this.farmName,
    required this.name,
    required this.capacity,
    required this.currentQuantity,
    required this.status,
    this.observations,
    this.createdAt,
    this.updatedAt,
  });

  factory SiloModel.fromJson(Map<String, dynamic> json) {
    return SiloModel(
      id: json['id'],
      farmId: json['farm'],
      farmName: json['farm_name'],
      name: json['name'],
      capacity: (json['capacity'] as num).toDouble(),
      currentQuantity: (json['current_quantity'] as num).toDouble(),
      status: json['status'],
      observations: json['observations'] ?? json['observacao'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm': farmId,
      'name': name,
      'capacity': capacity,
      'current_quantity': currentQuantity,
      'status': status,
      'observations': observations,
    };
  }

  double get percentage => (currentQuantity / capacity) * 100;
}
