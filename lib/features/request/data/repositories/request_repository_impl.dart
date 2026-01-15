import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/data/datasources/requests_datasource_impl.dart';
import 'package:jusconnect/features/request/data/models/request_model.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';

class RequestRepositoryImpl implements IRequestRepository {
  final RequestsDataSourceImpl dataSource;

  RequestRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<RequestEntity>>> getAllPublicRequests() async {
    try {
      final result = await dataSource.getAllPublicRequests();

      return result.fold(
        (failure) => Left(failure),
        (requests) => Right(requests.cast<RequestEntity>()),
      );
    } catch (e) {
      return Left(
        ServerFailure('Erro ao buscar solicitações públicas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getMyRequestsLawyer() async {
    try {
      final result = await dataSource.getMyRequestsLawyer();

      return result.fold(
        (failure) => Left(failure),
        (requests) => Right(requests.cast<RequestEntity>()),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar solicitações do advogado: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<RequestEntity>>> getMyRequestsClient() async {
    try {
      final result = await dataSource.getMyRequestsClient();

      return result.fold(
        (failure) => Left(failure),
        (requests) => Right(requests.cast<RequestEntity>()),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          'Erro ao buscar solicitações do cliente: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, RequestEntity>> getRequest(int requestId) async {
    try {
      final result = await dataSource.getRequest(requestId);

      return result.fold(
        (failure) => Left(failure),
        (request) => Right(request),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar solicitação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createRequest(RequestModel request) async {
    try {
      return await dataSource.createRequest(request);
    } catch (e) {
      return Left(ServerFailure('Erro ao criar solicitação: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequest(RequestModel request) async {
    try {
      return await dataSource.updateRequest(request);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao atualizar solicitação: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest(int requestId) async {
    try {
      return await dataSource.cancelRequest(requestId);
    } catch (e) {
      return Left(
        ServerFailure('Erro ao cancelar solicitação: ${e.toString()}'),
      );
    }
  }
}
