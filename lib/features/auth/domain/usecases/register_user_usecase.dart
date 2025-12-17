import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await repository.register(
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
