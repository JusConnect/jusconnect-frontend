import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class GetCurrentLawyerUseCase {
  final LawyerRepository repository;

  GetCurrentLawyerUseCase(this.repository);

  Future<Either<Failure, LawyerEntity?>> call() {
    return repository.getCurrentLawyer();
  }
}
