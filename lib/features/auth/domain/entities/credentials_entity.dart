import 'package:equatable/equatable.dart';

class CredentialsEntity extends Equatable {
  final String cpf;
  final String password;

  const CredentialsEntity({required this.cpf, required this.password});

  @override
  List<Object?> get props => [cpf, password];
}
