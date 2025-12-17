import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/auth/data/models/user_model.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthLocalDataSourceImpl dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> getProfile(String userId) async {
    try {
      final currentUser = await dataSource.getCurrentUser();

      if (currentUser == null) {
        return const Left(NotFoundFailure('Usuário não encontrado'));
      }

      if (currentUser.id != userId) {
        return const Left(AuthFailure('Não autorizado'));
      }

      return Right(currentUser);
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final currentUser = await dataSource.getCurrentUser();

      if (currentUser == null) {
        return const Left(NotFoundFailure('Usuário não encontrado'));
      }

      if (currentUser.id != user.id) {
        return const Left(AuthFailure('Não autorizado'));
      }

      final updatedUser = UserModel.fromEntity(user);
      await dataSource.saveUser(updatedUser);

      return Right(updatedUser);
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }
}
