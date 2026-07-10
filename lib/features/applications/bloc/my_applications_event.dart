import 'package:equatable/equatable.dart';
import '../models/application.dart';

sealed class MyApplicationsEvent extends Equatable {
  const MyApplicationsEvent();
  @override
  List<Object?> get props => [];
}

class MyApplicationsSubscriptionRequested extends MyApplicationsEvent {
  final String studentUid;
  const MyApplicationsSubscriptionRequested(this.studentUid);
  @override
  List<Object?> get props => [studentUid];
}

class MyApplicationsUpdated extends MyApplicationsEvent {
  final List<Application> applications;
  const MyApplicationsUpdated(this.applications);
  @override
  List<Object?> get props => [applications];
}

class MyApplicationsFailed extends MyApplicationsEvent {
  final String message;
  const MyApplicationsFailed(this.message);
  @override
  List<Object?> get props => [message];
}
