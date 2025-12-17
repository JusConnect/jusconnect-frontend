import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/auth/data/models/user_model.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSourceImpl dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final existingUser = await dataSource.getUserByCpf(email);
      if (existingUser != null) {
        return const Left(DuplicateFailure('Email já cadastrado'));
      }

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        cpf: cpf,
        email: email,
        phone: phone,
      );

      await dataSource.saveUserWithPassword(user, password);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao registrar usuário: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    CredentialsEntity credentials,
  ) async {
    try {
      final user = await dataSource.getUserByCpf(credentials.cpf);

      if (user == null) {
        return const Left(AuthFailure('Email ou senha incorretos'));
      }

      final isPasswordValid = await dataSource.validatePassword(
        credentials.cpf,
        credentials.password,
      );

      if (!isPasswordValid) {
        return const Left(AuthFailure('Email ou senha incorretos'));
      }

      await dataSource.saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.removeUser();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar usuário: ${e.toString()}'));
    }
  }
}
