import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../opportunities/data/opportunity_repository.dart';
import '../../opportunities/models/opportunity.dart';
import '../data/bookmark_repository.dart';
import 'saved_opportunities_event.dart';
import 'saved_opportunities_state.dart';

/// Firestore has no server-side join, so this combines two independent
/// streams (a user's bookmarked ids, and every opportunity) client-side —
/// same pattern as AdminUsersBloc joining users onto startups.
class SavedOpportunitiesBloc extends Bloc<SavedOpportunitiesEvent, SavedOpportunitiesState> {
  SavedOpportunitiesBloc(this._bookmarkRepository, this._opportunityRepository)
      : super(const SavedOpportunitiesLoading()) {
    on<SavedOpportunitiesSubscriptionRequested>(_onSubscriptionRequested);
    on<SavedOpportunitiesBookmarkIdsUpdated>(_onIdsUpdated);
    on<SavedOpportunitiesOpportunitiesUpdated>(_onOpportunitiesUpdated);
    on<SavedOpportunitiesFailed>(_onFailed);
  }

  final BookmarkRepository _bookmarkRepository;
  final OpportunityRepository _opportunityRepository;
  StreamSubscription<Set<String>>? _idsSubscription;
  StreamSubscription<List<Opportunity>>? _opportunitiesSubscription;

  Set<String> _ids = {};
  List<Opportunity> _allOpportunities = [];
  bool _hasIds = false;
  bool _hasOpportunities = false;

  Future<void> _onSubscriptionRequested(
    SavedOpportunitiesSubscriptionRequested event,
    Emitter<SavedOpportunitiesState> emit,
  ) async {
    await _idsSubscription?.cancel();
    await _opportunitiesSubscription?.cancel();
    _idsSubscription = _bookmarkRepository.bookmarkedIdsStream(event.uid).listen(
          (ids) => add(SavedOpportunitiesBookmarkIdsUpdated(ids)),
          onError: (error) => add(SavedOpportunitiesFailed(error.toString())),
        );
    _opportunitiesSubscription = _opportunityRepository.allOpportunitiesStream().listen(
          (list) => add(SavedOpportunitiesOpportunitiesUpdated(list)),
          onError: (error) => add(SavedOpportunitiesFailed(error.toString())),
        );
  }

  void _onIdsUpdated(
    SavedOpportunitiesBookmarkIdsUpdated event,
    Emitter<SavedOpportunitiesState> emit,
  ) {
    _ids = event.ids;
    _hasIds = true;
    _emitCombined(emit);
  }

  void _onOpportunitiesUpdated(
    SavedOpportunitiesOpportunitiesUpdated event,
    Emitter<SavedOpportunitiesState> emit,
  ) {
    _allOpportunities = event.opportunities;
    _hasOpportunities = true;
    _emitCombined(emit);
  }

  void _emitCombined(Emitter<SavedOpportunitiesState> emit) {
    if (!_hasIds || !_hasOpportunities) return;
    final saved = _allOpportunities.where((o) => _ids.contains(o.id)).toList();
    emit(SavedOpportunitiesLoaded(saved));
  }

  void _onFailed(SavedOpportunitiesFailed event, Emitter<SavedOpportunitiesState> emit) {
    emit(SavedOpportunitiesError(event.message));
  }

  @override
  Future<void> close() {
    _idsSubscription?.cancel();
    _opportunitiesSubscription?.cancel();
    return super.close();
  }
}
