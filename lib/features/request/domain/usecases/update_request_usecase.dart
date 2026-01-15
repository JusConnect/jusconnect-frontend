import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/data/models/request_model.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';

class UpdateRequestUseCase {
  final IRequestRepository repository;

  UpdateRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(RequestModel request) async {
    return await repository.updateRequest(request);
  }
}
