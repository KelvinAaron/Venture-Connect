import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Single source of truth for auth state. Login/sign-up handlers only call
/// the repository and surface failures; success is always driven by the
/// authStateChanges subscription below, so there is never a race between
/// two different code paths both deciding when the user is "authenticated".
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthRoleSelectionSubmitted>(_onRoleSelectionSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);

    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<User?> _authSubscription;

  Future<void> _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) async {
    final firebaseUser = event.firebaseUser;
    if (firebaseUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    emit(const AuthLoading());
    final profile = await _authRepository.getUserProfile(firebaseUser.uid);
    if (profile != null) {
      emit(AuthAuthenticated(profile));
      return;
    }

    final isGoogleUser = firebaseUser.providerData.any((p) => p.providerId == 'google.com');
    if (isGoogleUser) {
      // First-time Google sign-in: no Firestore doc yet since Google skips
      // our signup form's role picker. Route to role selection instead of
      // treating this the same as a broken/orphaned account.
      emit(AuthNeedsRoleSelection(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
      ));
      return;
    }

    emit(const AuthFailure('Could not load your profile. Please try logging in again.'));
    await _authRepository.logout();
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.login(email: event.email, password: event.password);
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_friendlyMessage(e)));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_friendlyMessage(e)));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signInWithGoogle();
      // success -> authStateChanges listener drives the rest
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        emit(AuthFailure(e.description ?? 'Google sign-in failed.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_friendlyMessage(e)));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onRoleSelectionSubmitted(
    AuthRoleSelectionSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthNeedsRoleSelection) return;
    emit(current.copyWith(isSubmitting: true, error: null));
    try {
      await _authRepository.createProfile(
        uid: current.uid,
        name: current.name,
        email: current.email,
        role: event.role,
      );
      final profile = await _authRepository.getUserProfile(current.uid);
      if (profile != null) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(current.copyWith(isSubmitting: false, error: 'Could not finish setting up your account.'));
      }
    } catch (e) {
      emit(current.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'invalid-email':
        return 'That email address looks invalid.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
