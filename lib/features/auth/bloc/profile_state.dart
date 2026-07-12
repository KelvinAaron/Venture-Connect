import 'package:equatable/equatable.dart';
import '../models/app_user.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final AppUser? user;
  final bool isSaving;
  final String? error;  
  final DateTime? _errorAt;

  const ProfileState({
    this.isLoading = true,
    this.user,
    this.isSaving = false,
    this.error,
    this._errorAt,
  });

  ProfileState copyWith({bool? isLoading, AppUser? user, bool? isSaving, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      errorAt: error != null ? DateTime.now() : null,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, isSaving, error, _errorAt];
}
