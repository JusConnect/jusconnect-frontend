import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class GetAllLawyersUseCase {
  final LawyerRepository repository;

  GetAllLawyersUseCase(this.repository);

  Future<Either<Failure, List<LawyerEntity>>> call() async {
    return await repository.getAllLawyers();
  }
}
