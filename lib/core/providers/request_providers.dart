import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/app_providers.dart';
import 'package:jusconnect/features/request/data/datasources/requests_datasource_impl.dart';
import 'package:jusconnect/features/request/data/repositories/request_repository_impl.dart';
import 'package:jusconnect/features/request/domain/repositories/request_repository.dart';
import 'package:jusconnect/features/request/domain/usecases/cancel_request_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/create_request_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/get_all_public_requests_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/get_my_requests_client_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/get_my_requests_lawyer_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/get_request_usecase.dart';
import 'package:jusconnect/features/request/domain/usecases/update_request_usecase.dart';

final requestsDataSourceProvider = Provider<RequestsDataSourceImpl>((ref) {
  final networkHandler = ref.watch(networkHandlerProvider);
  final authDataSource = ref.watch(authLocalDataSourceProvider);
  return RequestsDataSourceImpl(networkHandler, authDataSource);
});

final requestRepositoryProvider = Provider<IRequestRepository>((ref) {
  final dataSource = ref.read(requestsDataSourceProvider);
  return RequestRepositoryImpl(dataSource);
});

final getAllPublicRequestsUseCaseProvider =
    Provider<GetAllPublicRequestsUseCase>((ref) {
      final repository = ref.read(requestRepositoryProvider);
      return GetAllPublicRequestsUseCase(repository);
    });

final getMyRequestsLawyerUseCaseProvider = Provider<GetMyRequestsLawyerUseCase>(
  (ref) {
    final repository = ref.read(requestRepositoryProvider);
    return GetMyRequestsLawyerUseCase(repository);
  },
);

final getMyRequestsClientUseCaseProvider = Provider<GetMyRequestsClientUseCase>(
  (ref) {
    final repository = ref.read(requestRepositoryProvider);
    return GetMyRequestsClientUseCase(repository);
  },
);

final getRequestUseCaseProvider = Provider<GetRequestUseCase>((ref) {
  final repository = ref.read(requestRepositoryProvider);
  return GetRequestUseCase(repository);
});

final createRequestUseCaseProvider = Provider<CreateRequestUseCase>((ref) {
  final repository = ref.read(requestRepositoryProvider);
  return CreateRequestUseCase(repository);
});

final updateRequestUseCaseProvider = Provider<UpdateRequestUseCase>((ref) {
  final repository = ref.read(requestRepositoryProvider);
  return UpdateRequestUseCase(repository);
});

final cancelRequestUseCaseProvider = Provider<CancelRequestUseCase>((ref) {
  final repository = ref.read(requestRepositoryProvider);
  return CancelRequestUseCase(repository);
});
