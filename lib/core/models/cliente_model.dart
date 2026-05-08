class ClienteModel {
  final int? id;
  final String nome;
  final String? email;
  final String? telefone;
  final String? cpfCnpj;
  final String? endereco;
  final DateTime? createdAt;

  ClienteModel({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.cpfCnpj,
    this.endereco,
    this.createdAt,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) {
    return ClienteModel(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      cpfCnpj: json['cpf_cnpj'],
      endereco: json['endereco'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf_cnpj': cpfCnpj,
      'endereco': endereco,
    };
  }
}
