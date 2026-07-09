import 'package:equatable/equatable.dart';
import '../models/startup.dart';

sealed class StartupProfileState extends Equatable {
  const StartupProfileState();
  @override
  List<Object?> get props => [];
}

class StartupProfileLoading extends StartupProfileState {
  const StartupProfileLoading();
}

/// No startups/{uid} doc exists yet -> show the creation form.
class StartupProfileNotCreated extends StartupProfileState {
  final bool isSubmitting;
  final String? error;
  const StartupProfileNotCreated({this.isSubmitting = false, this.error});
  @override
  List<Object?> get props => [isSubmitting, error];
}

/// Profile exists but status is pending or rejected -> not yet allowed to
/// post opportunities. The screen branches on [startup.status] for copy.
class StartupProfileAwaitingDecision extends StartupProfileState {
  final Startup startup;
  const StartupProfileAwaitingDecision(this.startup);
  @override
  List<Object?> get props => [startup];
}

class StartupProfileVerified extends StartupProfileState {
  final Startup startup;
  const StartupProfileVerified(this.startup);
  @override
  List<Object?> get props => [startup];
}
