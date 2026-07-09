import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final uid = credential.user!.uid;
    final user = AppUser(uid: uid, name: name.trim(), email: email.trim(), role: role);
    await _users.doc(uid).set(user.toMap());
  }

  Future<void> login({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> logout() => _firebaseAuth.signOut();

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
}
