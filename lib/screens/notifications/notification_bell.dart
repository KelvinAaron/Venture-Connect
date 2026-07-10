import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/notifications/bloc/notifications_bloc.dart';
import '../../features/notifications/bloc/notifications_event.dart';
import '../../features/notifications/bloc/notifications_state.dart';
import '../../features/notifications/data/notification_repository.dart';
import 'notifications_screen.dart';

/// AppBar action for student/startup home screens — bell icon with an
/// unread-count badge, pushing NotificationsScreen on tap.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => NotificationsBloc(NotificationRepository())
        ..add(NotificationsSubscriptionRequested(authState.user.uid)),
      child: Builder(
        builder: (context) {
          final unreadCount = context.select<NotificationsBloc, int>((bloc) {
            final state = bloc.state;
            return state is NotificationsLoaded ? state.unreadCount : 0;
          });
          return IconButton(
            icon: Badge(
              label: Text('$unreadCount'),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Notifications',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          );
        },
      ),
    );
  }
}
