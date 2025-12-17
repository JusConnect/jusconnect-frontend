import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/lawyer_providers.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_auth_state.dart';

class LawyerAuthNotifier extends StateNotifier<LawyerAuthState> {
  final Ref ref;

  LawyerAuthNotifier(this.ref) : super(LawyerAuthInitial()) {
    _checkCurrentLawyer();
  }

  Future<void> _checkCurrentLawyer() async {
    final useCase = ref.read(getCurrentLawyerUseCaseProvider);
    final result = await useCase();

    result.fold((failure) => state = LawyerAuthInitial(), (lawyer) {
      if (lawyer != null) {
        state = LawyerAuthSuccess(lawyer);
      } else {
        state = LawyerAuthInitial();
      }
    });
  }

  Future<void> register({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) async {
    state = LawyerAuthLoading();

    final useCase = ref.read(registerLawyerUseCaseProvider);
    final result = await useCase(
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
      areaOfExpertise: areaOfExpertise,
      description: description,
      videoUrl: videoUrl,
    );

    result.fold(
      (failure) => state = LawyerAuthError(failure.message),
      (lawyer) => state = LawyerAuthSuccess(lawyer),
    );
  }

  Future<void> login({required String cpf, required String password}) async {
    state = LawyerAuthLoading();

    final useCase = ref.read(loginLawyerUseCaseProvider);
    final credentials = CredentialsEntity(cpf: cpf, password: password);
    final result = await useCase(credentials);

    result.fold(
      (failure) => state = LawyerAuthError(failure.message),
      (lawyer) => state = LawyerAuthSuccess(lawyer),
    );
  }

  Future<void> logout() async {
    state = LawyerAuthLoading();

    final useCase = ref.read(logoutLawyerUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) => state = LawyerAuthError(failure.message),
      (_) => state = LawyerAuthLoggedOut(),
    );
  }

  LawyerEntity? get currentLawyer {
    if (state is LawyerAuthSuccess) {
      return (state as LawyerAuthSuccess).lawyer;
    }
    return null;
  }
}

final lawyerAuthProvider =
    StateNotifierProvider<LawyerAuthNotifier, LawyerAuthState>((ref) {
      return LawyerAuthNotifier(ref);
    });
