import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class LogoutLawyerUseCase {
  final LawyerRepository repository;

  LogoutLawyerUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
