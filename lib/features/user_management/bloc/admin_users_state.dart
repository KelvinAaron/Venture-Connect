import 'package:equatable/equatable.dart';
import '../models/admin_user_row.dart';

sealed class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserRow> rows;
  final Set<String> processingStartupIds;
  const AdminUsersLoaded({required this.rows, this.processingStartupIds = const {}});
  @override
  List<Object?> get props => [rows, processingStartupIds];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
  @override
  List<Object?> get props => [message];
}
