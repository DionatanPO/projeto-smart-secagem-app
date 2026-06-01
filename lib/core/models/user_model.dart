class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? password;
  final String accountType;
  final bool isStaff;
  final String firstName;
  final String lastName;
  final String? telefone;
  final int? unidadeArmazenadora;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.password,
    required this.accountType,
    this.isStaff = false,
    this.firstName = '',
    this.lastName = '',
    this.telefone,
    this.unidadeArmazenadora,
  });

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      accountType: json['account_type'] ?? 'operador',
      isStaff: json['is_staff'] ?? false,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      telefone: json['telefone'],
      unidadeArmazenadora: json['unidade_armazenadora'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'account_type': accountType,
    };
    if (firstName.isNotEmpty) data['first_name'] = firstName;
    if (lastName.isNotEmpty) data['last_name'] = lastName;
    if (telefone != null) data['telefone'] = telefone;
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    if (unidadeArmazenadora != null) data['unidade_armazenadora'] = unidadeArmazenadora;
    return data;
  }
}
