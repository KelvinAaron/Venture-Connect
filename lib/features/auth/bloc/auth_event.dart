import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Internal event fired whenever FirebaseAuth's own auth state changes.
class AuthUserChanged extends AuthEvent {
  final User? firebaseUser;
  const AuthUserChanged(this.firebaseUser);
  @override
  List<Object?> get props => [firebaseUser?.uid];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserRole role;
  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
  @override
  List<Object?> get props => [name, email, password, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

/// Submits the role chosen on RoleSelectionScreen for a first-time Google
/// sign-in, completing that account's Firestore profile.
class AuthRoleSelectionSubmitted extends AuthEvent {
  final UserRole role;
  const AuthRoleSelectionSubmitted(this.role);
  @override
  List<Object?> get props => [role];
}
