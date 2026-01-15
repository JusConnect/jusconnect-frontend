import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';

class CancelRequestUseCase {
  final IRequestRepository repository;

  CancelRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(int requestId) async {
    return await repository.cancelRequest(requestId);
  }
}
