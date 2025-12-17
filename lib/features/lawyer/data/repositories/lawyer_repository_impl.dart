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
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) async {
    try {
      final lawyer = await dataSource.registerLawyer(
        name: name,
        cpf: cpf,
        email: email,
        phone: phone,
        password: password,
        areaOfExpertise: areaOfExpertise,
        description: description,
        videoUrl: videoUrl,
      );
      return Right(lawyer);
    } catch (e) {
      if (e.toString().contains('já cadastrado')) {
        return Left(DuplicateFailure('CPF já cadastrado'));
      }
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> login(
    CredentialsEntity credentials,
  ) async {
    try {
      final lawyer = await dataSource.login(
        credentials.cpf,
        credentials.password,
      );

      if (lawyer == null) {
        return Left(AuthFailure('CPF ou senha inválidos'));
      }

      return Right(lawyer);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer login'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await dataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Erro ao fazer logout'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity?>> getCurrentLawyer() async {
    try {
      final lawyer = await dataSource.getCurrentLawyer();
      return Right(lawyer);
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar advogado atual'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> getProfile(String id) async {
    try {
      final lawyer = await dataSource.getLawyerById(id);

      if (lawyer == null) {
        return Left(NotFoundFailure('Advogado não encontrado'));
      }

      return Right(lawyer);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar perfil'));
    }
  }

  @override
  Future<Either<Failure, LawyerEntity>> updateProfile({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) async {
    try {
      final currentLawyer = await dataSource.getLawyerById(id);

      if (currentLawyer == null) {
        return Left(NotFoundFailure('Advogado não encontrado'));
      }

      final updatedLawyer = LawyerModel(
        id: id,
        name: name,
        cpf: currentLawyer.cpf,
        email: email,
        phone: phone,
        areaOfExpertise: areaOfExpertise,
        description: description,
        videoUrl: videoUrl,
        createdAt: currentLawyer.createdAt,
      );

      final result = await dataSource.updateLawyer(updatedLawyer);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar perfil'));
    }
  }
}
