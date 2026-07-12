import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import 'my_opportunities_event.dart';
import 'my_opportunities_state.dart';

class MyOpportunitiesBloc extends Bloc<MyOpportunitiesEvent, MyOpportunitiesState> {
  MyOpportunitiesBloc(this._repository) : super(const MyOpportunitiesLoading()) {
    on<MyOpportunitiesSubscriptionRequested>(_onSubscriptionRequested);
    on<MyOpportunitiesUpdated>(_onUpdated);
    on<MyOpportunitiesFailed>(_onFailed);
    on<MyOpportunitiesOpenToggled>(_onOpenToggled);
  }

  final OpportunityRepository _repository;
  StreamSubscription<List<Opportunity>>? _subscription;

  Future<void> _onSubscriptionRequested(
    MyOpportunitiesSubscriptionRequested event,
    Emitter<MyOpportunitiesState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.myOpportunitiesStream(event.startupId).listen(
          (list) => add(MyOpportunitiesUpdated(list)),
          onError: (error) => add(MyOpportunitiesFailed(error.toString())),
        );
  }

  void _onUpdated(MyOpportunitiesUpdated event, Emitter<MyOpportunitiesState> emit) {
    emit(MyOpportunitiesLoaded(opportunities: event.opportunities));
  }

  void _onFailed(MyOpportunitiesFailed event, Emitter<MyOpportunitiesState> emit) {
    emit(MyOpportunitiesError(event.message));
  }

  Future<void> _onOpenToggled(
    MyOpportunitiesOpenToggled event,
    Emitter<MyOpportunitiesState> emit,
  ) async {
    final current = state;
    if (current is! MyOpportunitiesLoaded) return;
    emit(MyOpportunitiesLoaded(
      opportunities: current.opportunities,
      processingIds: {...current.processingIds, event.opportunityId},
    ));
    try {
      await _repository.setOpen(event.opportunityId, event.isOpen);
    } catch (_) {
      final latest = state;
      if (latest is MyOpportunitiesLoaded) {
        emit(MyOpportunitiesLoaded(
          opportunities: latest.opportunities,
          processingIds: {...latest.processingIds}..remove(event.opportunityId),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
