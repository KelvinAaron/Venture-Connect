import 'package:equatable/equatable.dart';
import '../models/application.dart';

sealed class MyApplicationsState extends Equatable {
  const MyApplicationsState();
  @override
  List<Object?> get props => [];
}

class MyApplicationsLoading extends MyApplicationsState {
  const MyApplicationsLoading();
}

class MyApplicationsLoaded extends MyApplicationsState {
  final List<Application> applications;
  const MyApplicationsLoaded(this.applications);
  @override
  List<Object?> get props => [applications];
}

class MyApplicationsError extends MyApplicationsState {
  final String message;
  const MyApplicationsError(this.message);
  @override
  List<Object?> get props => [message];
}
