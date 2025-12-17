import 'package:jusconnect/features/lawyer/domain/entities/lawyer_entity.dart';

abstract class LawyerProfileState {
  const LawyerProfileState();
}

class LawyerProfileInitial extends LawyerProfileState {}

class LawyerProfileLoading extends LawyerProfileState {}

class LawyerProfileLoaded extends LawyerProfileState {
  final LawyerEntity lawyer;

  const LawyerProfileLoaded(this.lawyer);
}

class LawyerProfileError extends LawyerProfileState {
  final String message;

  const LawyerProfileError(this.message);
}

class LawyerProfileUpdating extends LawyerProfileState {}

class LawyerProfileUpdated extends LawyerProfileState {
  final LawyerEntity lawyer;

  const LawyerProfileUpdated(this.lawyer);
}
