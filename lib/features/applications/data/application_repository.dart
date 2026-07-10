import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../models/application_status.dart';

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications => _firestore.collection('applications');

  /// Deterministic doc id makes "has this student already applied to this
  /// opportunity" a direct doc lookup instead of a query, and makes
  /// duplicate applications structurally impossible (a second `apply` call
  /// just overwrites the same doc rather than creating a second one).
  String _docId(String opportunityId, String studentUid) => '${opportunityId}_$studentUid';

  Stream<Application?> applicationStream(String opportunityId, String studentUid) {
    return _applications.doc(_docId(opportunityId, studentUid)).snapshots().map(
          (doc) => doc.exists ? Application.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<void> apply({
    required String opportunityId,
    required String opportunityTitle,
    required String startupId,
    required String startupName,
    required String studentUid,
    required String studentName,
  }) async {
    final application = Application(
      id: _docId(opportunityId, studentUid),
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId,
      startupName: startupName,
      studentUid: studentUid,
      studentName: studentName,
      status: ApplicationStatus.applied,
    );
    await _applications.doc(application.id).set(application.toCreateMap());
  }

  /// One student's own applications, for "My Applications". Filters
  /// server-side on `studentUid`, sorts client-side by appliedAt.
  Stream<List<Application>> myApplicationsStream(String studentUid) {
    return _applications.where('studentUid', isEqualTo: studentUid).snapshots().map((snap) {
      final list = snap.docs.map((d) => Application.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.appliedAt ?? DateTime(0)).compareTo(a.appliedAt ?? DateTime(0)));
      return list;
    });
  }

  /// Every applicant for one posting, for the startup's "Applicants" view.
  Stream<List<Application>> applicantsForOpportunityStream(String opportunityId) {
    return _applications.where('opportunityId', isEqualTo: opportunityId).snapshots().map((snap) {
      final list = snap.docs.map((d) => Application.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (a.appliedAt ?? DateTime(0)).compareTo(b.appliedAt ?? DateTime(0)));
      return list;
    });
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) {
    return _applications.doc(applicationId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
