import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import 'opportunity_feed_event.dart';
import 'opportunity_feed_state.dart';

class OpportunityFeedBloc extends Bloc<OpportunityFeedEvent, OpportunityFeedState> {
  OpportunityFeedBloc(this._repository) : super(const OpportunityFeedState()) {
    on<OpportunityFeedSubscriptionRequested>(_onSubscriptionRequested);
    on<OpportunityFeedUpdated>(_onUpdated);
    on<OpportunityFeedFailed>(_onFailed);
    on<OpportunityFeedSearchChanged>(_onSearchChanged);
    on<OpportunityFeedCategoryChanged>(_onCategoryChanged);
  }

  final OpportunityRepository _repository;
  StreamSubscription<List<Opportunity>>? _subscription;

  Future<void> _onSubscriptionRequested(
    OpportunityFeedSubscriptionRequested event,
    Emitter<OpportunityFeedState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.openOpportunitiesStream().listen(
          (list) => add(OpportunityFeedUpdated(list)),
          onError: (error) => add(OpportunityFeedFailed(error.toString())),
        );
  }

  void _onUpdated(OpportunityFeedUpdated event, Emitter<OpportunityFeedState> emit) {
    emit(state.copyWith(status: OpportunityFeedStatus.loaded, all: event.opportunities));
  }

  void _onFailed(OpportunityFeedFailed event, Emitter<OpportunityFeedState> emit) {
    emit(state.copyWith(status: OpportunityFeedStatus.error, errorMessage: event.message));
  }

  void _onSearchChanged(OpportunityFeedSearchChanged event, Emitter<OpportunityFeedState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onCategoryChanged(
    OpportunityFeedCategoryChanged event,
    Emitter<OpportunityFeedState> emit,
  ) {
    emit(state.copyWith(category: () => event.category));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
