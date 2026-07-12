import 'package:cloud_firestore/cloud_firestore.dart';
import '../../notifications/data/notification_repository.dart';
import '../models/startup.dart';
import '../models/verification_status.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups => _firestore.collection('startups');

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

  // get startups by status
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

  // gets all startups regardless of status 
  Stream<List<Startup>> allStartupsStream() {
    return _startups.snapshots().map(
          (snap) => snap.docs.map((d) => Startup.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> decide(String startupId, {required bool approve}) async {
    final batch = _firestore.batch();
    batch.update(_startups.doc(startupId), {
      'status': (approve ? VerificationStatus.verified : VerificationStatus.rejected).name,
      'decidedAt': FieldValue.serverTimestamp(),
    });
    NotificationRepository.queue(
      batch,
      _firestore,
      uid: startupId, 
      title: approve ? 'Startup verified' : 'Startup not approved',
      body: approve
          ? 'Your startup is verified — you can now post opportunities.'
          : 'Your startup profile was not approved. Contact the ALU admin team for details.',
      type: 'startupVerification',
    );
    await batch.commit();
  }

  // edit start-up profile
  Future<void> updateProfile({
    required String startupId,
    required String name,
    required String description,
    required String category,
    required String website,
  }) {
    return _startups.doc(startupId).update({
      'name': name,
      'description': description,
      'category': category,
      'website': website,
    });
  }
}
