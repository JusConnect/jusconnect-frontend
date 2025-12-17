import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

abstract class LawyerAuthState {
  const LawyerAuthState();
}

class LawyerAuthInitial extends LawyerAuthState {}

class LawyerAuthLoading extends LawyerAuthState {}

class LawyerAuthSuccess extends LawyerAuthState {
  final LawyerEntity lawyer;

  const LawyerAuthSuccess(this.lawyer);
}

class LawyerAuthError extends LawyerAuthState {
  final String message;

  const LawyerAuthError(this.message);
}

class LawyerAuthLoggedOut extends LawyerAuthState {}
