import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/lawyer_providers.dart';
import 'package:jusconnect/features/lawyer/presentation/providers/lawyer_profile_state.dart';

class LawyerProfileNotifier extends StateNotifier<LawyerProfileState> {
  final Ref ref;

  LawyerProfileNotifier(this.ref) : super(LawyerProfileInitial());

  Future<void> loadProfile(int id) async {
    state = LawyerProfileLoading();

    final useCase = ref.read(getLawyerProfileUseCaseProvider);
    final result = await useCase(id);

    result.fold(
      (failure) => state = LawyerProfileError(failure.message),
      (lawyer) => state = LawyerProfileLoaded(lawyer),
    );
  }

  Future<void> updateProfile({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String areaOfExpertise,
    required String description,
    String? videoUrl,
  }) async {
    state = LawyerProfileUpdating();

    final useCase = ref.read(updateLawyerProfileUseCaseProvider);
    final result = await useCase(
      id: id,
      name: name,
      email: email,
      phone: phone,
      areaOfExpertise: areaOfExpertise,
      description: description,
      videoUrl: videoUrl,
    );

    result.fold(
      (failure) => state = LawyerProfileError(failure.message),
      (lawyer) => state = LawyerProfileUpdated(lawyer),
    );
  }
}

final lawyerProfileProvider =
    StateNotifierProvider<LawyerProfileNotifier, LawyerProfileState>((ref) {
      return LawyerProfileNotifier(ref);
    });
