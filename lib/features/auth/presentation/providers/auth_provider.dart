import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/app_providers.dart';
import 'package:jusconnect/features/auth/domain/entities/credentials_entity.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(AuthInitialState()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    final result = await useCase();

    result.fold((failure) => state = AuthInitialState(), (user) {
      if (user != null) {
        state = AuthSuccessState(user);
      } else {
        state = AuthInitialState();
      }
    });
  }

  Future<void> register({
    required String name,
    required String cpf,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = AuthLoadingState();

    final useCase = ref.read(registerUserUseCaseProvider);
    final result = await useCase(
      name: name,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
    );

    result.fold(
      (failure) => state = AuthErrorState(failure.message),
      (user) => state = AuthSuccessState(user),
    );
  }

  Future<void> login({required String cpf, required String password}) async {
    state = AuthLoadingState();

    final useCase = ref.read(loginUseCaseProvider);
    final credentials = CredentialsEntity(cpf: cpf, password: password);
    final result = await useCase(credentials);

    result.fold(
      (failure) => state = AuthErrorState(failure.message),
      (user) => state = AuthSuccessState(user),
    );
  }

  Future<void> logout() async {
    state = AuthLoadingState();

    final useCase = ref.read(logoutUseCaseProvider);
    final result = await useCase();

    result.fold(
      (failure) => state = AuthErrorState(failure.message),
      (_) => state = AuthLoggedOutState(),
    );
  }

  UserEntity? get currentUser {
    if (state is AuthSuccessState) {
      return (state as AuthSuccessState).user;
    }
    return null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
