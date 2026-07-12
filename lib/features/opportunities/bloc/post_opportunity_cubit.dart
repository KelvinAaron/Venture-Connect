import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import 'post_opportunity_state.dart';

// handles creating and edit a posting since the state management is direct
class PostOpportunityCubit extends Cubit<PostOpportunityState> {
  PostOpportunityCubit(this._repository) : super(const PostOpportunityIdle());

  final OpportunityRepository _repository;

  Future<void> create(Opportunity opportunity) async {
    if (state is PostOpportunitySubmitting) return;
    emit(const PostOpportunitySubmitting());
    try {
      await _repository.createOpportunity(opportunity);
      emit(const PostOpportunitySuccess());
    } catch (e) {
      emit(PostOpportunityFailure(e.toString()));
    }
  }

  Future<void> update(Opportunity opportunity) async {
    if (state is PostOpportunitySubmitting) return;
    emit(const PostOpportunitySubmitting());
    try {
      await _repository.updateOpportunity(opportunity);
      emit(const PostOpportunitySuccess());
    } catch (e) {
      emit(PostOpportunityFailure(e.toString()));
    }
  }
}
