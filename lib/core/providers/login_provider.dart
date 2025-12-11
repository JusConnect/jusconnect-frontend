import 'package:riverpod/riverpod.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  LoginState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  LoginState copyWith({bool? isLoading, String? error, bool? isAuthenticated}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class LoginNotifier extends Notifier<LoginState> {
  LoginNotifier() : super();

  Future<void> login() async {
    
    print("Login process started");
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(seconds: 2));
    try {
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    state = LoginState();
  }

  @override
  LoginState build() {
    return LoginState();
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(() {
  return LoginNotifier();
});
