import 'package:equatable/equatable.dart';
import '../models/opportunity.dart';

sealed class OpportunityFeedEvent extends Equatable {
  const OpportunityFeedEvent();
  @override
  List<Object?> get props => [];
}

class OpportunityFeedSubscriptionRequested extends OpportunityFeedEvent {
  const OpportunityFeedSubscriptionRequested();
}

class OpportunityFeedUpdated extends OpportunityFeedEvent {
  final List<Opportunity> opportunities;
  const OpportunityFeedUpdated(this.opportunities);
  @override
  List<Object?> get props => [opportunities];
}

class OpportunityFeedFailed extends OpportunityFeedEvent {
  final String message;
  const OpportunityFeedFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class OpportunityFeedSearchChanged extends OpportunityFeedEvent {
  final String query;
  const OpportunityFeedSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

// Pass null to clear the category filter.
class OpportunityFeedCategoryChanged extends OpportunityFeedEvent {
  final String? category;
  const OpportunityFeedCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}
