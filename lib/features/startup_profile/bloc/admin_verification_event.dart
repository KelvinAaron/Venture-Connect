import 'package:equatable/equatable.dart';
import '../models/startup.dart';

sealed class AdminVerificationEvent extends Equatable {
  const AdminVerificationEvent();
  @override
  List<Object?> get props => [];
}

class AdminVerificationSubscriptionRequested extends AdminVerificationEvent {
  const AdminVerificationSubscriptionRequested();
}

class AdminVerificationListUpdated extends AdminVerificationEvent {
  final List<Startup> startups;
  const AdminVerificationListUpdated(this.startups);
  @override
  List<Object?> get props => [startups];
}

class AdminVerificationFailed extends AdminVerificationEvent {
  final String message;
  const AdminVerificationFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminVerificationDecided extends AdminVerificationEvent {
  final String startupId;
  final bool approve;
  const AdminVerificationDecided({required this.startupId, required this.approve});
  @override
  List<Object?> get props => [startupId, approve];
}
