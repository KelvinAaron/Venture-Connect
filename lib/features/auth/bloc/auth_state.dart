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

/// A login/sign-up attempt failed, or a signed-in user's profile could not
/// be loaded. Screens surface [message]; routing treats this the same as
/// AuthUnauthenticated (stay on/return to the login screen).
class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}
