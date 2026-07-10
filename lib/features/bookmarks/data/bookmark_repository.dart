import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkRepository {
  BookmarkRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _bookmarks(String uid) =>
      _firestore.collection('users').doc(uid).collection('bookmarks');

  /// Doc id == opportunityId, so checking/toggling a single bookmark never
  /// needs a query.
  Stream<bool> isBookmarkedStream(String uid, String opportunityId) {
    return _bookmarks(uid).doc(opportunityId).snapshots().map((doc) => doc.exists);
  }

  Stream<Set<String>> bookmarkedIdsStream(String uid) {
    return _bookmarks(uid).snapshots().map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  Future<void> setBookmarked(String uid, String opportunityId, bool bookmarked) {
    final doc = _bookmarks(uid).doc(opportunityId);
    if (bookmarked) {
      return doc.set({'opportunityId': opportunityId, 'savedAt': FieldValue.serverTimestamp()});
    }
    return doc.delete();
  }
}
