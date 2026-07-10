import 'package:equatable/equatable.dart';
import '../models/application.dart';

sealed class ApplyState extends Equatable {
  const ApplyState();
  @override
  List<Object?> get props => [];
}

class ApplyLoading extends ApplyState {
  const ApplyLoading();
}

class ApplyNotApplied extends ApplyState {
  const ApplyNotApplied();
}

class ApplyInProgress extends ApplyState {
  const ApplyInProgress();
}

class ApplyApplied extends ApplyState {
  final Application application;
  const ApplyApplied(this.application);
  @override
  List<Object?> get props => [application];
}

class ApplyError extends ApplyState {
  final String message;
  const ApplyError(this.message);
  @override
  List<Object?> get props => [message];
}
