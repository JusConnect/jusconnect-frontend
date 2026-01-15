import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/domain/repositories/auth_repository.dart';

class RegisterUserUseCase {
  final IAuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
  }) async {
    var result = await repository.register(
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
    );

    var loginResult = await repository.login(
      CredentialsEntity(cpf: cpf, password: password),
    );
    var loginFailure = loginResult.fold<Failure?>((l) => l, (_) => null);
    if (loginFailure != null) {
      return Left(loginFailure);
    }

    return result;
  }
}
