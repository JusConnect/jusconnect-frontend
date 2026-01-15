import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/features/request/data/models/request_model.dart';

abstract class IRequestRepository {
  Future<Either<Failure, List<RequestEntity>>> getAllPublicRequests();
  Future<Either<Failure, List<RequestEntity>>> getMyRequestsLawyer();
  Future<Either<Failure, List<RequestEntity>>> getMyRequestsClient();
  Future<Either<Failure, RequestEntity>> getRequest(int requestId);
  Future<Either<Failure, void>> createRequest(RequestModel request);
  Future<Either<Failure, void>> updateRequest(RequestModel request);
  Future<Either<Failure, void>> cancelRequest(int requestId);
}
