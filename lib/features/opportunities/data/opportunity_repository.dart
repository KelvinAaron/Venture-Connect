import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');

  // get all open posting, for the student discovery feed
  Stream<List<Opportunity>> openOpportunitiesStream() {
    return _opportunities.where('isOpen', isEqualTo: true).snapshots().map((snap) {
      final list = snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  /// get all postings for a startup
  Stream<List<Opportunity>> myOpportunitiesStream(String startupId) {
    return _opportunities.where('startupId', isEqualTo: startupId).snapshots().map((snap) {
      final list = snap.docs.map((d) => Opportunity.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  // get all posting
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
