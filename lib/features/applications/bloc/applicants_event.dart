import 'package:equatable/equatable.dart';
import '../models/application.dart';
import '../models/application_status.dart';

sealed class ApplicantsEvent extends Equatable {
  const ApplicantsEvent();
  @override
  List<Object?> get props => [];
}

class ApplicantsSubscriptionRequested extends ApplicantsEvent {
  final String opportunityId;
  const ApplicantsSubscriptionRequested(this.opportunityId);
  @override
  List<Object?> get props => [opportunityId];
}

class ApplicantsUpdated extends ApplicantsEvent {
  final List<Application> applicants;
  const ApplicantsUpdated(this.applicants);
  @override
  List<Object?> get props => [applicants];
}

class ApplicantsFailed extends ApplicantsEvent {
  final String message;
  const ApplicantsFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class ApplicantsStatusChanged extends ApplicantsEvent {
  final Application application;
  final ApplicationStatus status;
  const ApplicantsStatusChanged({required this.application, required this.status});
  @override
  List<Object?> get props => [application, status];
}
