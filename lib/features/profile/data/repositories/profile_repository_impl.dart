import 'package:dartz/dartz.dart';
import 'package:jusconnect/core/errors/failures.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/auth/data/models/user_model.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AuthDataSourceImpl dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, UserEntity>> getProfile(int userId) async {
    try {
      final currentUser = await dataSource.getCurrentUser();

      return currentUser.fold(
        (failure) => Left(failure),
        (userModel) => Right(userModel.toEntity()),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao buscar perfil: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile(UserEntity user) async {
    try {
      final updatedUser = UserModel.fromEntity(user);
      final updateResult = await dataSource.updateUser(updatedUser);

      if (updateResult.isLeft()) {
        final result = updateResult.fold<Failure?>((l) => (l), (r) => (null));
        if (result != null) return Left(result);
      }

      final profileResult = await dataSource.getCurrentUser();

      return profileResult.fold(
        (failure) => Left(failure),
        (userModel) => Right(userModel.toEntity()),
      );
    } catch (e) {
      return Left(AuthFailure('Erro ao atualizar perfil: ${e.toString()}'));
    }
  }
}
