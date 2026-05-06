class SecadorModel {
  final int? id;
  final int farmId;
  final String? farmName;
  final String nome;
  final String tipo; // Coluna, Cascata, Fluxo Contínuo, etc.
  final double capacidade; // Toneladas por hora (t/h)
  final String fonteCalor; // Lenha, Gás GLP, Biomassa, etc.
  final String status; // Ativo, Manutenção, Inativo
  final String? observacoes;

  SecadorModel({
    this.id,
    required this.farmId,
    this.farmName,
    required this.nome,
    required this.tipo,
    required this.capacidade,
    required this.fonteCalor,
    required this.status,
    this.observacoes,
  });

  factory SecadorModel.fromJson(Map<String, dynamic> json) {
    return SecadorModel(
      id: json['id'],
      farmId: json['farm'] ?? json['farm_id'],
      farmName: json['farm_name'],
      nome: json['nome'] ?? json['name'],
      tipo: json['tipo'] ?? json['type'],
      capacidade: (json['capacidade'] ?? json['capacity'] ?? 0.0).toDouble(),
      fonteCalor: json['fonte_calor'] ?? json['fuel_source'] ?? 'Lenha',
      status: json['status'] ?? 'Ativo',
      observacoes: json['observacoes'] ?? json['observations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'farm': farmId,
      'nome': nome,
      'tipo': tipo,
      'capacidade': capacidade,
      'fonte_calor': fonteCalor,
      'status': status,
      'observacoes': observacoes,
    };
  }
}
