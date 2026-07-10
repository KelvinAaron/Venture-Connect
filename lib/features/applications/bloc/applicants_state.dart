import 'package:equatable/equatable.dart';
import '../models/application.dart';

sealed class ApplicantsState extends Equatable {
  const ApplicantsState();
  @override
  List<Object?> get props => [];
}

class ApplicantsLoading extends ApplicantsState {
  const ApplicantsLoading();
}

class ApplicantsLoaded extends ApplicantsState {
  final List<Application> applicants;
  final Set<String> processingIds;
  const ApplicantsLoaded({required this.applicants, this.processingIds = const {}});
  @override
  List<Object?> get props => [applicants, processingIds];
}

class ApplicantsError extends ApplicantsState {
  final String message;
  const ApplicantsError(this.message);
  @override
  List<Object?> get props => [message];
}
