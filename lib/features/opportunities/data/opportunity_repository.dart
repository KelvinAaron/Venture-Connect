import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');

  /// Every open posting, for the student discovery feed. Filters
  /// server-side on `isOpen`, sorts client-side by createdAt — same
  /// index-avoidance approach used elsewhere in this app.
  Stream<List<Opportunity>> openOpportunitiesStream() {
    return _opportunities.where('isOpen', isEqualTo: true).snapshots().map((snap) {
      final list = snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  /// All of one startup's postings (open and closed), for their own
  /// "My postings" management view.
  Stream<List<Opportunity>> myOpportunitiesStream(String startupId) {
    return _opportunities.where('startupId', isEqualTo: startupId).snapshots().map((snap) {
      final list = snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  /// Every posting regardless of owner or status — used to resolve a
  /// student's bookmarked opportunity ids into full Opportunity data
  /// (a bookmarked posting may have since been closed, so this
  /// deliberately isn't limited to openOpportunitiesStream).
  Stream<List<Opportunity>> allOpportunitiesStream() {
    return _opportunities.snapshots().map(
          (snap) => snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> createOpportunity(Opportunity opportunity) {
    return _opportunities.add(opportunity.toCreateMap());
  }

  Future<void> updateOpportunity(Opportunity opportunity) {
    return _opportunities.doc(opportunity.id).update(opportunity.toUpdateMap());
  }

  Future<void> setOpen(String opportunityId, bool isOpen) {
    return _opportunities.doc(opportunityId).update({'isOpen': isOpen});
  }
}
