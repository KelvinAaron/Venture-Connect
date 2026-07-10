import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String uid) =>
      _firestore.collection('users').doc(uid).collection('notifications');

  Stream<List<AppNotification>> notificationsStream(String uid) {
    return _notifications(uid).snapshots().map((snap) {
      final list = snap.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      return list;
    });
  }

  Future<void> markRead(String uid, String notificationId) {
    return _notifications(uid).doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllRead(String uid, List<String> notificationIds) async {
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.update(_notifications(uid).doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  /// Queues a notification write into an existing [batch] so other
  /// repositories (applications, startup verification) can attach a
  /// notification to the same atomic write as their own mutation, without
  /// each needing to know the `users/{uid}/notifications` schema/path
  /// themselves.
  static void queue(
    WriteBatch batch,
    FirebaseFirestore firestore, {
    required String uid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) {
    final ref = firestore.collection('users').doc(uid).collection('notifications').doc();
    batch.set(ref, {
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
