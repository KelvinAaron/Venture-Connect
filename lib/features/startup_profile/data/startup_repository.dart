import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup.dart';
import '../models/verification_status.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups => _firestore.collection('startups');

  /// Streams the calling startup owner's own profile (or null if they
  /// haven't created one yet). Doc id == ownerUid, so this is a direct doc
  /// lookup, not a query.
  Stream<Startup?> myStartupStream(String ownerUid) {
    return _startups.doc(ownerUid).snapshots().map(
          (doc) => doc.exists ? Startup.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<void> createProfile({
    required String ownerUid,
    required String name,
    required String description,
    required String category,
    required String website,
  }) async {
    final startup = Startup(
      id: ownerUid,
      ownerUid: ownerUid,
      name: name,
      description: description,
      category: category,
      website: website,
      status: VerificationStatus.pending,
    );
    await _startups.doc(ownerUid).set(startup.toCreateMap());
  }

  /// Filters server-side on `status`, then sorts client-side by createdAt.
  /// Avoids requiring a manual composite Firestore index for a
  /// filter+orderBy combo, which isn't worth the setup friction at this
  /// project's scale.
  Stream<List<Startup>> pendingStartupsStream() {
    return _startups
        .where('status', isEqualTo: VerificationStatus.pending.name)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => Startup.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      return list;
    });
  }

  /// All startups regardless of status — used by the admin user-management
  /// view to join startup verification info onto every startup-role user.
  Stream<List<Startup>> allStartupsStream() {
    return _startups.snapshots().map(
          (snap) => snap.docs.map((d) => Startup.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> decide(String startupId, {required bool approve}) {
    return _startups.doc(startupId).update({
      'status': (approve ? VerificationStatus.verified : VerificationStatus.rejected).name,
      'decidedAt': FieldValue.serverTimestamp(),
    });
  }
}
