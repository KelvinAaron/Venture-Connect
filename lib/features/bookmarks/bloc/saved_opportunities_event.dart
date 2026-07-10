import 'package:equatable/equatable.dart';
import '../../opportunities/models/opportunity.dart';

sealed class SavedOpportunitiesEvent extends Equatable {
  const SavedOpportunitiesEvent();
  @override
  List<Object?> get props => [];
}

class SavedOpportunitiesSubscriptionRequested extends SavedOpportunitiesEvent {
  final String uid;
  const SavedOpportunitiesSubscriptionRequested(this.uid);
  @override
  List<Object?> get props => [uid];
}

class SavedOpportunitiesBookmarkIdsUpdated extends SavedOpportunitiesEvent {
  final Set<String> ids;
  const SavedOpportunitiesBookmarkIdsUpdated(this.ids);
  @override
  List<Object?> get props => [ids];
}

class SavedOpportunitiesOpportunitiesUpdated extends SavedOpportunitiesEvent {
  final List<Opportunity> opportunities;
  const SavedOpportunitiesOpportunitiesUpdated(this.opportunities);
  @override
  List<Object?> get props => [opportunities];
}

class SavedOpportunitiesFailed extends SavedOpportunitiesEvent {
  final String message;
  const SavedOpportunitiesFailed(this.message);
  @override
  List<Object?> get props => [message];
}
