import 'package:equatable/equatable.dart';
import '../models/app_notification.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsSubscriptionRequested extends NotificationsEvent {
  final String uid;
  const NotificationsSubscriptionRequested(this.uid);
  @override
  List<Object?> get props => [uid];
}

class NotificationsUpdated extends NotificationsEvent {
  final List<AppNotification> notifications;
  const NotificationsUpdated(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationsFailed extends NotificationsEvent {
  final String message;
  const NotificationsFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationMarkedRead extends NotificationsEvent {
  final String notificationId;
  const NotificationMarkedRead(this.notificationId);
  @override
  List<Object?> get props => [notificationId];
}

class NotificationsAllMarkedRead extends NotificationsEvent {
  const NotificationsAllMarkedRead();
}
