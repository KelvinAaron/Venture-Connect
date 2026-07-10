import 'package:equatable/equatable.dart';
import '../models/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Before the first authStateChanges event has arrived.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A firebase user exists and we're fetching/confirming their Firestore profile.
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// A Firebase Auth session exists (typically from a first-time Google
/// sign-in) but no Firestore `users/{uid}` doc has been created yet, since
/// Google sign-in skips our custom signup form's role picker.
class AuthNeedsRoleSelection extends AuthState {
  final String uid;
  final String name;
  final String email;
  final bool isSubmitting;
  final String? error;

  const AuthNeedsRoleSelection({
    required this.uid,
    required this.name,
    required this.email,
    this.isSubmitting = false,
    this.error,
  });

  AuthNeedsRoleSelection copyWith({bool? isSubmitting, String? error}) {
    return AuthNeedsRoleSelection(
      uid: uid,
      name: name,
      email: email,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, isSubmitting, error];
}

/// A login/sign-up attempt failed, or a signed-in user's profile could not
/// be loaded. Screens surface [message]; routing treats this the same as
/// AuthUnauthenticated (stay on/return to the login screen).
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
