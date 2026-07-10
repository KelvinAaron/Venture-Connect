import 'package:equatable/equatable.dart';
import '../models/opportunity.dart';

sealed class MyOpportunitiesEvent extends Equatable {
  const MyOpportunitiesEvent();
  @override
  List<Object?> get props => [];
}

class MyOpportunitiesSubscriptionRequested extends MyOpportunitiesEvent {
  final String startupId;
  const MyOpportunitiesSubscriptionRequested(this.startupId);
  @override
  List<Object?> get props => [startupId];
}

class MyOpportunitiesUpdated extends MyOpportunitiesEvent {
  final List<Opportunity> opportunities;
  const MyOpportunitiesUpdated(this.opportunities);
  @override
  List<Object?> get props => [opportunities];
}

class MyOpportunitiesFailed extends MyOpportunitiesEvent {
  final String message;
  const MyOpportunitiesFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class MyOpportunitiesOpenToggled extends MyOpportunitiesEvent {
  final String opportunityId;
  final bool isOpen;
  const MyOpportunitiesOpenToggled({required this.opportunityId, required this.isOpen});
  @override
  List<Object?> get props => [opportunityId, isOpen];
}
