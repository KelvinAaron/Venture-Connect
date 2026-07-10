import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await createProfile(uid: credential.user!.uid, name: name.trim(), email: email.trim(), role: role);
  }

  Future<void> login({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Starts an interactive Google sign-in and exchanges the resulting ID
  /// token for a Firebase credential. If this is the account's first sign-in
  /// there won't be a Firestore profile yet — AuthBloc detects that case and
  /// routes to role selection instead of treating it as an error.
  ///
  /// Assumes [GoogleSignIn.instance] was already initialized once at app
  /// startup (see main.dart) — initialize() must only ever be called once
  /// per app run.
  Future<void> signInWithGoogle() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: "Google didn't return an ID token. Please try again.",
      );
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Writes the Firestore `users/{uid}` profile doc. Used both by [signUp]
  /// (email/password) and by the role-selection flow that follows a
  /// first-time Google sign-in.
  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final user = AppUser(uid: uid, name: name, email: email, role: role);
    await _users.doc(uid).set(user.toMap());
  }

  /// Polls briefly for the Firestore profile doc. It's written right after
  /// the Firebase Auth account is created, so it can lag the
  /// authStateChanges event by a few hundred milliseconds during sign-up.
  Future<AppUser?> getUserProfile(String uid) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final doc = await _users.doc(uid).get();
      if (doc.exists) return AppUser.fromMap(uid, doc.data()!);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return null;
  }

  /// Live version of [getUserProfile], for the profile screen.
  Stream<AppUser?> userProfileStream(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
        );
  }

  Future<void> updateProfile(AppUser user) {
    return _users.doc(user.uid).update({
      'name': user.name,
      'skills': user.skills,
      'interests': user.interests,
      'bio': user.bio,
    });
  }
}
