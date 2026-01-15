import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/auth/data/models/user_model.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthDataSourceImpl dataSource;

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
      final user = UserModel(
        id: 0,
        name: name,
        cpf: cpf,
        email: email,
        phone: phone,
      );

      final result = await dataSource.createUser(user, password);

      return result.fold(
        (failure) => Left(failure),
        (user) => Right(user.toEntity()),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao registrar usuário: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
    CredentialsEntity credentials,
  ) async {
    try {
      final result = await dataSource.login(credentials);
      final failure = result.fold<Failure?>((l) => l, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final userResult = await dataSource.getCurrentUser();

      return userResult.fold(
        (failure) => Left(failure),
        (userModel) => Right(userModel.toEntity()),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      return await dataSource.logout();
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userResult = await dataSource.getCurrentUser();

      return userResult.fold(
        (failure) => Left(failure),
        (userModel) => Right(userModel.toEntity()),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar usuário: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserModel user) async {
    try {
      final currentUserResult = await dataSource.getCurrentUser();
      final failure = currentUserResult.fold<Failure?>((l) => l, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final currentUser = currentUserResult.fold<UserModel?>(
        (l) => null,
        (r) => r,
      );

      user = currentUser!.copyWith(
        email: user.email,
        name: user.name,
        phone: user.phone,
      );

      final userResult = await dataSource.updateUser(user);

      final updateFailure = userResult.fold<Failure?>((l) => l, (_) => null);
      if (updateFailure != null) {
        return Left(updateFailure);
      }

      return await getCurrentUser();
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar usuário: ${e.toString()}'));
    }
  }
}
