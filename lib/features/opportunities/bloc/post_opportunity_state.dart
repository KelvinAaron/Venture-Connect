import 'package:equatable/equatable.dart';

sealed class PostOpportunityState extends Equatable {
  const PostOpportunityState();
  @override
  List<Object?> get props => [];
}

class PostOpportunityIdle extends PostOpportunityState {
  const PostOpportunityIdle();
}

class PostOpportunitySubmitting extends PostOpportunityState {
  const PostOpportunitySubmitting();
}

class PostOpportunitySuccess extends PostOpportunityState {
  const PostOpportunitySuccess();
}

class PostOpportunityFailure extends PostOpportunityState {
  final String message;
  const PostOpportunityFailure(this.message);
  @override
  List<Object?> get props => [message];
}
