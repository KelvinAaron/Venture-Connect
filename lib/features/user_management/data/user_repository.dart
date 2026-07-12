import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/models/app_user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  // Every account in the system
  Stream<List<AppUser>> allUsersStream() {
    return _users.snapshots().map((snap) {
      final list = snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      return list;
    });
  }
}
