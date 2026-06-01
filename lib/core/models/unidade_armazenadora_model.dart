class UnidadeArmazenadoraModel {
  final int? id;
  final String name;
  final String? location;
  final String? description;
  final int? owner;
  final DateTime? createdAt;

  UnidadeArmazenadoraModel({
    this.id,
    required this.name,
    this.location,
    this.description,
    this.owner,
    this.createdAt,
  });

  factory UnidadeArmazenadoraModel.fromJson(Map<String, dynamic> json) {
    return UnidadeArmazenadoraModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      owner: json['owner'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'owner': owner,
    };
  }
}
