import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class GetLawyerProfileUseCase {
  final LawyerRepository repository;

  GetLawyerProfileUseCase(this.repository);

  Future<Either<Failure, LawyerEntity>> call(String id) {
    return repository.getProfile(id);
  }
}
