import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.email,
    required super.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'cpf': cpf, 'email': email, 'phone': phone};
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
}
