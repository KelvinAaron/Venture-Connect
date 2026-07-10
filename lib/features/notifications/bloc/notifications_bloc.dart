import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notification_repository.dart';
import '../models/app_notification.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._repository) : super(const NotificationsLoading()) {
    on<NotificationsSubscriptionRequested>(_onSubscriptionRequested);
    on<NotificationsUpdated>(_onUpdated);
    on<NotificationsFailed>(_onFailed);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsAllMarkedRead>(_onAllMarkedRead);
  }

  final NotificationRepository _repository;
  StreamSubscription<List<AppNotification>>? _subscription;
  String? _uid;

  Future<void> _onSubscriptionRequested(
    NotificationsSubscriptionRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    _uid = event.uid;
    await _subscription?.cancel();
    _subscription = _repository.notificationsStream(event.uid).listen(
          (list) => add(NotificationsUpdated(list)),
          onError: (error) => add(NotificationsFailed(error.toString())),
        );
  }

  void _onUpdated(NotificationsUpdated event, Emitter<NotificationsState> emit) {
    emit(NotificationsLoaded(event.notifications));
  }

  void _onFailed(NotificationsFailed event, Emitter<NotificationsState> emit) {
    emit(NotificationsError(event.message));
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.markRead(uid, event.notificationId);
  }

  Future<void> _onAllMarkedRead(
    NotificationsAllMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final uid = _uid;
    final current = state;
    if (uid == null || current is! NotificationsLoaded) return;
    final unreadIds = current.notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;
    await _repository.markAllRead(uid, unreadIds);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
