import 'package:equatable/equatable.dart';
import '../../auth/models/app_user.dart';
import '../../startup_profile/models/startup.dart';

sealed class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override
  List<Object?> get props => [];
}

class AdminUsersSubscriptionRequested extends AdminUsersEvent {
  const AdminUsersSubscriptionRequested();
}

class AdminUsersUsersUpdated extends AdminUsersEvent {
  final List<AppUser> users;
  const AdminUsersUsersUpdated(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminUsersStartupsUpdated extends AdminUsersEvent {
  final List<Startup> startups;
  const AdminUsersStartupsUpdated(this.startups);
  @override
  List<Object?> get props => [startups];
}

class AdminUsersFailed extends AdminUsersEvent {
  final String message;
  const AdminUsersFailed(this.message);
  @override
  List<Object?> get props => [message];
}

/// Lets the admin approve/reject a startup directly from user management,
/// same underlying action as the dedicated verifications queue.
class AdminUsersStartupDecided extends AdminUsersEvent {
  final String startupId;
  final bool approve;
  const AdminUsersStartupDecided({required this.startupId, required this.approve});
  @override
  List<Object?> get props => [startupId, approve];
}
