import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import '../models/app_user.dart';
import 'profile_state.dart';

/// Streams the signed-in user's own profile doc and drives edits to it.
/// Kept separate from AuthBloc (which only fetches the profile once at
/// sign-in) so editing skills/interests/bio doesn't need AuthBloc itself
/// to become a live subscription.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, {required this.uid}) : super(const ProfileState()) {
    _subscription = _repository.userProfileStream(uid).listen(
          (user) => emit(state.copyWith(isLoading: false, user: user)),
        );
  }

  final AuthRepository _repository;
  final String uid;
  late final StreamSubscription<AppUser?> _subscription;

  Future<void> save({
    required String name,
    required List<String> skills,
    required List<String> interests,
    required String bio,
  }) async {
    final current = state.user;
    if (current == null) return;
    emit(state.copyWith(isSaving: true));
    try {
      await _repository.updateProfile(
        current.copyWith(name: name, skills: skills, interests: interests, bio: bio),
      );
      // stream listener will refresh `user`; still need to clear isSaving.
      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
