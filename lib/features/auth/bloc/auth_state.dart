import 'package:equatable/equatable.dart';
import '../models/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

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

// when signingup with google ask for role
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

class AuthFailure extends AuthState {
  final String message;
  final DateTime _at;
  AuthFailure(this.message) : _at = DateTime.now();
  @override
  List<Object?> get props => [message, _at];
}
