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

  // handles sign-in with google
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

  // writes user to firestore
  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final user = AppUser(uid: uid, name: name, email: email, role: role);
    await _users.doc(uid).set(user.toMap());
  }

  // delay authStateChanges event by a few hundred milliseconds during sign-up
  Future<AppUser?> getUserProfile(String uid) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final doc = await _users.doc(uid).get();
      if (doc.exists) return AppUser.fromMap(uid, doc.data()!);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    return null;
  }

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
