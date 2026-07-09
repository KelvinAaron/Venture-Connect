import 'package:equatable/equatable.dart';
import '../models/startup.dart';

sealed class AdminVerificationState extends Equatable {
  const AdminVerificationState();
  @override
  List<Object?> get props => [];
}

class AdminVerificationLoading extends AdminVerificationState {
  const AdminVerificationLoading();
}

class AdminVerificationLoaded extends AdminVerificationState {
  final List<Startup> pending;
  final Set<String> processingIds;
  const AdminVerificationLoaded({required this.pending, this.processingIds = const {}});
  @override
  List<Object?> get props => [pending, processingIds];
}

class AdminVerificationError extends AdminVerificationState {
  final String message;
  const AdminVerificationError(this.message);
  @override
  List<Object?> get props => [message];
}
