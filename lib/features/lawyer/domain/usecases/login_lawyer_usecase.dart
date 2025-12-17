import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class LoginLawyerUseCase {
  final LawyerRepository repository;

  LoginLawyerUseCase(this.repository);

  Future<Either<Failure, LawyerEntity>> call(CredentialsEntity credentials) {
    return repository.login(credentials);
  }
}
