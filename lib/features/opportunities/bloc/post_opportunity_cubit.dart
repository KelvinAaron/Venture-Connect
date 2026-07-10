import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import 'post_opportunity_state.dart';

/// Drives PostOpportunityScreen's submit action, for both creating a new
/// posting and editing an existing one. Kept separate from
/// MyOpportunitiesBloc since that bloc's job is streaming/display, not
/// one-shot form submission.
class PostOpportunityCubit extends Cubit<PostOpportunityState> {
  PostOpportunityCubit(this._repository) : super(const PostOpportunityIdle());

  final OpportunityRepository _repository;

  Future<void> create(Opportunity opportunity) async {
    emit(const PostOpportunitySubmitting());
    try {
      await _repository.createOpportunity(opportunity);
      emit(const PostOpportunitySuccess());
    } catch (e) {
      emit(PostOpportunityFailure(e.toString()));
    }
  }

  Future<void> update(Opportunity opportunity) async {
    emit(const PostOpportunitySubmitting());
    try {
      await _repository.updateOpportunity(opportunity);
      emit(const PostOpportunitySuccess());
    } catch (e) {
      emit(PostOpportunityFailure(e.toString()));
    }
  }
}
