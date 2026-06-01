class SiloModel {
  final int? id;
  final int? unidadeArmazenadoraId;
  final String? unidadeArmazenadoraNome;
  final String name;
  final String tipo;
  final double capacity;
  final double currentQuantity;
  final String status;
  final String? observations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SiloModel({
    this.id,
    this.unidadeArmazenadoraId,
    this.unidadeArmazenadoraNome,
    required this.name,
    this.tipo = 'pulmao',
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
      unidadeArmazenadoraId: json['unidade_armazenadora'],
      unidadeArmazenadoraNome: json['unidade_armazenadora_nome'],
      name: json['name'],
      tipo: json['tipo'] ?? 'pulmao',
      capacity: (json['capacity'] as num? ?? 0.0).toDouble(),
      currentQuantity: (json['current_quantity'] as num? ?? 0.0).toDouble(),
      status: json['status'],
      observations: json['observations'] ?? json['observacao'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unidade_armazenadora': unidadeArmazenadoraId,
      'name': name,
      'tipo': tipo,
      'capacity': capacity,
      'current_quantity': currentQuantity,
      'status': status,
      'observations': observations,
    };
  }

  double get percentage {
    if (capacity <= 0) return 0.0;
    return (currentQuantity / capacity) * 100;
  }
}
