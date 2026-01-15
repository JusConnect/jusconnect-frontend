import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/request/data/models/request_model.dart';

abstract class IRequestsDataSource {
  Future<Either<Failure, List<RequestModel>>> getAllPublicRequests();
  Future<Either<Failure, List<RequestModel>>> getMyRequestsLawyer();
  Future<Either<Failure, List<RequestModel>>> getMyRequestsClient();
  Future<Either<Failure, RequestModel>> getRequest(int requestId);
  Future<Either<Failure, void>> createRequest(RequestModel request);
  Future<Either<Failure, void>> updateRequest(RequestModel request);
  Future<Either<Failure, void>> cancelRequest(int requestId);
}

class RequestsDataSourceImpl implements IRequestsDataSource {
  final Dio _dio;
  final AuthDataSourceImpl _authDataSource;

  RequestsDataSourceImpl(this._dio, this._authDataSource);

  @override
  Future<Either<Failure, List<RequestModel>>> getAllPublicRequests() async {
    try {
      var result = await _dio.get('/solicitacoes/publicas');

      if (result.statusCode == 200) {
        final List<dynamic> data = result.data as List<dynamic>;
        final requests = data
            .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(requests);
      }

      return Left(ServerFailure('Erro ao buscar solicitações públicas'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar solicitações públicas: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RequestModel>>> getMyRequestsLawyer() async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.get(
        '/solicitacoes/advogado',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 200) {
        final List<dynamic> data = result.data as List<dynamic>;
        final requests = data
            .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(requests);
      }

      return Left(ServerFailure('Erro ao buscar solicitações do advogado'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar solicitações do advogado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RequestModel>>> getMyRequestsClient() async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.get(
        '/solicitacoes/cliente',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 200) {
        final List<dynamic> data = result.data as List<dynamic>;
        final requests = data
            .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(requests);
      }

      return Left(ServerFailure('Erro ao buscar solicitações do cliente'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar solicitações do cliente: $e'));
    }
  }

  @override
  Future<Either<Failure, RequestModel>> getRequest(int requestId) async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.get(
        '/solicitacoes/$requestId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 200) {
        return Right(RequestModel.fromJson(result.data));
      }

      return Left(NotFoundFailure('Solicitação não encontrada'));
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar solicitação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createRequest(RequestModel request) async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.post(
        '/solicitacoes',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 201 || result.statusCode == 200) {
        return Right(null);
      }

      return Left(ServerFailure('Erro ao criar solicitação ${result.data}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao criar solicitação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequest(RequestModel request) async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.put(
        '/solicitacoes/${request.id}',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 200 || result.statusCode == 201) {
        return Right(null);
      }

      return Left(
        ServerFailure('Erro ao atualizar solicitação ${result.data}'),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar solicitação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(int requestId) async {
    final token = _authDataSource.authToken;
    if (token == null) {
      return Left(AuthFailure('Usuário não autenticado'));
    }

    try {
      var result = await _dio.delete(
        '/solicitacoes/$requestId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (result.statusCode == 204 || result.statusCode == 200) {
        return Right(null);
      }

      return Left(ServerFailure('Erro ao cancelar solicitação ${result.data}'));
    } catch (e) {
      return Left(ServerFailure('Erro ao cancelar solicitação: $e'));
    }
  }
}
