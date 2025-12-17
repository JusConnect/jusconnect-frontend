import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

abstract class LawyerRepository {
  Future<Either<Failure, LawyerEntity>> registerLawyer({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  });

  Future<Either<Failure, LawyerEntity>> login(CredentialsEntity credentials);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, LawyerEntity?>> getCurrentLawyer();

  Future<Either<Failure, LawyerEntity>> getProfile(String id);

  Future<Either<Failure, LawyerEntity>> updateProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  });
}
