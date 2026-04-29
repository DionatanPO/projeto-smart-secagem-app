class FarmModel {
  final int? id;
  final String name;
  final String? location;
  final String? description;
  final DateTime? createdAt;

  FarmModel({
    this.id,
    required this.name,
    this.location,
    this.description,
    this.createdAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
    };
  }
}
