import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:jusconnect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jusconnect/features/auth/domain/repositories/auth_repository.dart';
import 'package:jusconnect/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:jusconnect/features/auth/domain/usecases/login_usecase.dart';
import 'package:jusconnect/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jusconnect/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:jusconnect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:jusconnect/features/profile/domain/repositories/profile_repository.dart';
import 'package:jusconnect/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:jusconnect/features/profile/domain/usecases/update_profile_usecase.dart';

final networkHandlerProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080',
      validateStatus: (status) {
        return true;
      },
      receiveDataWhenStatusError: true,
    ),
  );
});

final authLocalDataSourceProvider = Provider<AuthDataSourceImpl>((ref) {
  final networkHandler = ref.watch(networkHandlerProvider);
  return AuthDataSourceImpl(networkHandler);
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(authLocalDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});

final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUserUseCase(repository);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetProfileUseCase(repository);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});
