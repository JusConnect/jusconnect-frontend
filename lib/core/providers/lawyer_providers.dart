import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/app_providers.dart';
import 'package:jusconnect/features/lawyer/data/datasources/lawyer_local_datasource.dart';
import 'package:jusconnect/features/lawyer/data/repositories/lawyer_repository_impl.dart';
import 'package:jusconnect/features/lawyer/domain/repositories/lawyer_repository.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/get_all_lawyers_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/get_current_lawyer_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/get_lawyer_profile_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/login_lawyer_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/logout_lawyer_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/register_lawyer_usecase.dart';
import 'package:jusconnect/features/lawyer/domain/usecases/update_lawyer_profile_usecase.dart';

final lawyerLocalDataSourceProvider = Provider<LawyerLocalDataSourceImpl>((
  ref,
) {
  final networkHandler = ref.watch(networkHandlerProvider);
  return LawyerLocalDataSourceImpl(
    networkHandler,
    ref.read(authLocalDataSourceProvider),
  );
});

final lawyerRepositoryProvider = Provider<LawyerRepository>((ref) {
  final dataSource = ref.read(lawyerLocalDataSourceProvider);
  return LawyerRepositoryImpl(dataSource);
});

final registerLawyerUseCaseProvider = Provider<RegisterLawyerUseCase>((ref) {
  final repository = ref.read(lawyerRepositoryProvider);
  return RegisterLawyerUseCase(repository);
});

final loginLawyerUseCaseProvider = Provider<LoginLawyerUseCase>((ref) {
  final repository = ref.read(lawyerRepositoryProvider);
  return LoginLawyerUseCase(repository);
});

final logoutLawyerUseCaseProvider = Provider<LogoutLawyerUseCase>((ref) {
  final repository = ref.read(lawyerRepositoryProvider);
  return LogoutLawyerUseCase(repository);
});

final getCurrentLawyerUseCaseProvider = Provider<GetCurrentLawyerUseCase>((
  ref,
) {
  final repository = ref.read(lawyerRepositoryProvider);
  return GetCurrentLawyerUseCase(repository);
});

final getLawyerProfileUseCaseProvider = Provider<GetLawyerProfileUseCase>((
  ref,
) {
  final repository = ref.read(lawyerRepositoryProvider);
  return GetLawyerProfileUseCase(repository);
});

final updateLawyerProfileUseCaseProvider = Provider<UpdateLawyerProfileUseCase>(
  (ref) {
    final repository = ref.read(lawyerRepositoryProvider);
    return UpdateLawyerProfileUseCase(repository);
  },
);

final getAllLawyersUseCaseProvider = Provider<GetAllLawyersUseCase>((ref) {
  final repository = ref.read(lawyerRepositoryProvider);
  return GetAllLawyersUseCase(repository);
});
