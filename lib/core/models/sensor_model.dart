class SensorModel {
  final int? id;
  final String sensorId;
  final int siloId;
  final String description;
  final String status;
  final String? siloName; // To display in the list

  SensorModel({
    this.id,
    required this.sensorId,
    required this.siloId,
    required this.description,
    required this.status,
    this.siloName,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'],
      sensorId: json['sensor_id'],
      siloId: json['silo'],
      description: json['description'],
      status: json['status'],
      siloName: json['silo_name'], // Assuming backend might return this through a serializer
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_id': sensorId,
      'silo': siloId,
      'description': description,
      'status': status,
    };
  }
}
