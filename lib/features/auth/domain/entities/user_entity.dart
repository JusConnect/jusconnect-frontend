import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String cpf;
  final String email;
  final String phone;

  const UserEntity({
    required this.id,
    required this.name,
    required this.cpf,
    required this.email,
    required this.phone,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? cpf,
    String? email,
    String? phone,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, cpf, email, phone];
}
