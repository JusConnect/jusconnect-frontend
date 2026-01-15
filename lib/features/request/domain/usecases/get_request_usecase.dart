import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';

class GetRequestUseCase {
  final IRequestRepository repository;

  GetRequestUseCase(this.repository);

  Future<Either<Failure, RequestEntity>> call(int requestId) async {
    return await repository.getRequest(requestId);
  }
}
