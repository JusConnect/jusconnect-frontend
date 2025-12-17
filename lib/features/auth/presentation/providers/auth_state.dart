import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final UserEntity user;
  AuthSuccessState(this.user);
}

class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

class AuthLoggedOutState extends AuthState {}
