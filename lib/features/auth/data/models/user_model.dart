import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? password;

  const UserModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.email,
    required super.phone,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['nome'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phone: json['telefone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nome': name, 'cpf': cpf, 'email': email, 'telefone': phone, "senha": password};
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      cpf: entity.cpf,
      email: entity.email,
      phone: entity.phone,
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: id, name: name, cpf: cpf, email: email, phone: phone);
  }

  @override
  UserModel copyWith({
    int? id,
    String? name,
    String? cpf,
    String? email,
    String? phone,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
