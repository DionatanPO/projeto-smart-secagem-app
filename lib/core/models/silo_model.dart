class SiloModel {
  final int? id;
  final String name;
  final double capacity;
  final double currentQuantity;
  final String productType;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiloModel({
    this.id,
    required this.name,
    required this.capacity,
    required this.currentQuantity,
    required this.productType,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory SiloModel.fromJson(Map<String, dynamic> json) {
    return SiloModel(
      id: json['id'],
      name: json['name'],
      capacity: (json['capacity'] as num).toDouble(),
      currentQuantity: (json['current_quantity'] as num).toDouble(),
      productType: json['product_type'],
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'current_quantity': currentQuantity,
      'product_type': productType,
      'status': status,
    };
  }

  double get percentage => (currentQuantity / capacity) * 100;
}
