import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

abstract class LawyerRepository {
  Future<Either<Failure, LawyerEntity>> registerLawyer({
    required LawyerModel lawyer,
  });

  Future<Either<Failure, LawyerEntity>> login(CredentialsEntity credentials);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, LawyerEntity?>> getCurrentLawyer();

  Future<Either<Failure, LawyerEntity>> getProfile(int id);

  Future<Either<Failure, LawyerEntity>> updateProfile({
    required LawyerModel lawyer,
  });

  Future<Either<Failure, List<LawyerEntity>>> getAllLawyers();
}
