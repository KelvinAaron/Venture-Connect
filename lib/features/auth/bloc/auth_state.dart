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
///
/// [_at] exists only so two consecutive failures with the same message are
/// never value-equal: Bloc's emit() silently no-ops when the new state ==
/// the current state, so without this a second identical failure (e.g.
/// wrong password twice in a row) would never actually emit — leaving
/// screens listening for it (to reset a loading spinner, for example)
/// stuck waiting for a state change that never happens.
class AuthFailure extends AuthState {
  final String message;
  final DateTime _at;
  AuthFailure(this.message) : _at = DateTime.now();
  @override
  List<Object?> get props => [message, _at];
}
