import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/request/domain/entities/request_entity.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';

class GetMyRequestsLawyerUseCase {
  final IRequestRepository repository;

  GetMyRequestsLawyerUseCase(this.repository);

  Future<Either<Failure, List<RequestEntity>>> call() async {
    return await repository.getMyRequestsLawyer();
  }
}
