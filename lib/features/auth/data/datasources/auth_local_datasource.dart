import 'package:dio/dio.dart';
import 'package:jusconnect/features/auth/data/models/user_model.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';

abstract class IAuthDataSource {
  Future<Either<Failure, UserModel>> getCurrentUser();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, UserModel>> createUser(
    UserModel user,
    String password,
  );
  Future<Either<Failure, void>> login(CredentialsEntity credentials);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> updateUser(UserModel user);
}

class AuthDataSourceImpl implements IAuthDataSource {
  static String? _authToken;
  final Dio _dio;

  AuthDataSourceImpl(this._dio);

  @override
  Future<Either<Failure, UserModel>> createUser(
    UserModel user,
    String password,
  ) async {
    try {
      user = user.copyWith(password: password);

      print(user.toJson());

      var result = await _dio.post('/clientes', data: user.toJson());

      if (result.statusCode == 201) {
        return Right(UserModel.fromJson(result.data));
      }

      return Left(AuthFailure('Erro ao criar usuário ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao criar usuário $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (_authToken == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.delete(
        '/clientes/me',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      if (result.statusCode == 204) {
        await logout();
        return Right(null);
      }

      return Left(AuthFailure('Erro ao deletar conta ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao deletar conta '));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    if (_authToken == null) {
      return Left(AuthFailure("Usuário não autenticado"));
    }

    try {
      var result = await _dio.get(
        '/clientes/me',
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      if (result.statusCode == 200) {
        return Right(UserModel.fromJson(result.data));
      }

      return Left(AuthFailure('Usuário não encontrado'));
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar usuário $e'));
    }
  }

  @override
  Future<Either<Failure, void>> login(CredentialsEntity credentials) async {
    var result = await _dio.post('/auth/login', data: credentials.toJson());
    if (result.statusCode == 200) {
      _authToken = result.data['token'];
      return Right(null);
    }
    return Left(AuthFailure('Erro ao fazer login ${result.data}'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    _authToken = null;
    return Right(null);
  }

  @override
  Future<Either<Failure, void>> updateUser(UserModel user) async {
    if (_authToken == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.put(
        '/clientes/me',
        data: user.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $_authToken'}),
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        return Right(null);
      }

      return Left(AuthFailure('Erro ao atualizar usuário ${result.data}'));
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar usuário $e'));
    }
  }

  String? get authToken => _authToken;
  set authToken(String? token) => _authToken = token;

  Future<Failure?> ensureAuth() async {
    if (_authToken == null) {
      return AuthFailure('Usuário não autenticado');
    }
    return null;
  }
}
