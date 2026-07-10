import 'package:equatable/equatable.dart';
import '../../auth/models/app_user.dart';
import '../../startup_profile/models/startup.dart';

/// A user paired with their startup profile, if they have one (role ==
/// startup and a `startups/{uid}` doc exists). Purely a read-model for the
/// admin user-management screen — nothing else needs this join.
class AdminUserRow extends Equatable {
  final AppUser user;
  final Startup? startup;

  const AdminUserRow({required this.user, this.startup});

  @override
  List<Object?> get props => [user, startup];
}
