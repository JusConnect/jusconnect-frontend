import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/core/providers/app_providers.dart';
import 'package:jusconnect/features/auth/domain/entities/user_entity.dart';
import 'package:jusconnect/features/profile/presentation/providers/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileNotifier(this.ref) : super(ProfileInitial());

  Future<void> loadProfile(String userId) async {
    state = ProfileLoading();

    final useCase = ref.read(getProfileUseCaseProvider);
    final result = await useCase(userId);

    result.fold(
      (failure) => state = ProfileError(failure.message),
      (user) => state = ProfileLoaded(user),
    );
  }

  Future<void> updateProfile(UserEntity user) async {
    state = ProfileUpdating();

    final useCase = ref.read(updateProfileUseCaseProvider);
    final result = await useCase(user);

    result.fold(
      (failure) => state = ProfileError(failure.message),
      (user) => state = ProfileUpdated(user),
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier(ref);
});
