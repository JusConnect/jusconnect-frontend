import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/data/datasources/lawyer_local_datasource.dart';
import 'package:jusconnect/features/lawyer/data/models/lawyer_model.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';

class LawyerRepositoryImpl implements LawyerRepository {
  final LawyerLocalDataSourceImpl dataSource;

  LawyerRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, LawyerEntity>> registerLawyer({
    required LawyerModel lawyer,
  }) async {
    try {
      final result = await dataSource.registerLawyer(lawyer: lawyer);

      return result.fold((failure) => Left(failure), (lawyer) => Right(lawyer));
    } catch (e) {
      return Left(ServerFailure('Erro ao registrar advogado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> login(
    CredentialsEntity credentials,
  ) async {
    try {
      final result = await dataSource.login(credentials);
      final failure = result.fold<Failure?>((l) => l, (_) => null);
      if (failure != null) {
        return Left(failure);
      }

      final lawyerResult = await dataSource.getCurrentLawyer();

      return lawyerResult.fold(
        (failure) => Left(failure),
        (lawyer) => Right(lawyer),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      return await dataSource.logout();
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity?>> getCurrentLawyer() async {
    try {
      final lawyerResult = await dataSource.getCurrentLawyer();

      return lawyerResult.fold(
        (failure) => Left(failure),
        (lawyer) => Right(lawyer),
      );
    } catch (e) {
      return Left(
        AuthFailure('Erro ao buscar advogado atual: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> getProfile(int id) async {
    try {
      final lawyerResult = await dataSource.getCurrentLawyer();

      return lawyerResult.fold(
        (failure) => Left(failure),
        (lawyer) => Right(lawyer),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> updateProfile({
    required LawyerModel lawyer,
  }) async {
    try {
      final currentLawyerResult = await dataSource.getCurrentLawyer();

      final currentLawyer = currentLawyerResult.fold<LawyerModel?>(
        (l) => null,
        (r) => r,
      );

      if (currentLawyer == null) {
        return Left(NotFoundFailure('Advogado não encontrado'));
      }

      final updatedLawyer = currentLawyer.copyWith(
        name: lawyer.name,
        email: lawyer.email,
        phone: lawyer.phone,
        areaOfExpertise: lawyer.areaOfExpertise,
        description: lawyer.description,
        videoUrl: lawyer.videoUrl,
      );

      final updateResult = await dataSource.updateLawyer(updatedLawyer);
      final updateFailure = updateResult.fold<Failure?>((l) => l, (_) => null);
      if (updateFailure != null) {
        return Left(updateFailure);
      }

      final profileResult = await dataSource.getCurrentLawyer();
      return profileResult.fold(
        (failure) => Left(failure),
        (lawyer) => Right(lawyer),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LawyerEntity>>> getAllLawyers() async {
    try {
      final lawyersResult = await dataSource.getAllLawyers();

      return lawyersResult.fold(
        (failure) => Left(failure),
        (lawyers) => Right(lawyers.cast<LawyerEntity>()),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar advogados: ${e.toString()}'));
    }
  }
}
