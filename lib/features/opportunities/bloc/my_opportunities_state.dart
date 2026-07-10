import 'package:equatable/equatable.dart';
import '../models/opportunity.dart';

sealed class MyOpportunitiesState extends Equatable {
  const MyOpportunitiesState();
  @override
  List<Object?> get props => [];
}

class MyOpportunitiesLoading extends MyOpportunitiesState {
  const MyOpportunitiesLoading();
}

class MyOpportunitiesLoaded extends MyOpportunitiesState {
  final List<Opportunity> opportunities;
  final Set<String> processingIds;
  const MyOpportunitiesLoaded({required this.opportunities, this.processingIds = const {}});
  @override
  List<Object?> get props => [opportunities, processingIds];
}

class MyOpportunitiesError extends MyOpportunitiesState {
  final String message;
  const MyOpportunitiesError(this.message);
  @override
  List<Object?> get props => [message];
}
