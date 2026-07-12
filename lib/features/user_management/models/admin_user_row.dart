import 'package:equatable/equatable.dart';
import '../../auth/models/app_user.dart';
import '../../startup_profile/models/startup.dart';

class AdminUserRow extends Equatable {
  final AppUser user;
  final Startup? startup;

  const AdminUserRow({required this.user, this.startup});

  @override
  List<Object?> get props => [user, startup];
}
