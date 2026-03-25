class UserModel {
  final int? id;
  final String username;
  final String email;
  final String? password;
  final String accountType;
  final bool isStaff;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.password,
    required this.accountType,
    this.isStaff = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      accountType: json['account_type'] ?? 'operador',
      isStaff: json['is_staff'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'account_type': accountType,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}
