import 'package:equatable/equatable.dart';
import '../../opportunities/models/opportunity.dart';

sealed class SavedOpportunitiesState extends Equatable {
  const SavedOpportunitiesState();
  @override
  List<Object?> get props => [];
}

class SavedOpportunitiesLoading extends SavedOpportunitiesState {
  const SavedOpportunitiesLoading();
}

class SavedOpportunitiesLoaded extends SavedOpportunitiesState {
  final List<Opportunity> opportunities;
  const SavedOpportunitiesLoaded(this.opportunities);
  @override
  List<Object?> get props => [opportunities];
}

class SavedOpportunitiesError extends SavedOpportunitiesState {
  final String message;
  const SavedOpportunitiesError(this.message);
  @override
  List<Object?> get props => [message];
}
