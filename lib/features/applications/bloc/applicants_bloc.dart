import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/application_repository.dart';
import '../models/application.dart';
import 'applicants_event.dart';
import 'applicants_state.dart';

class ApplicantsBloc extends Bloc<ApplicantsEvent, ApplicantsState> {
  ApplicantsBloc(this._repository) : super(const ApplicantsLoading()) {
    on<ApplicantsSubscriptionRequested>(_onSubscriptionRequested);
    on<ApplicantsUpdated>(_onUpdated);
    on<ApplicantsFailed>(_onFailed);
    on<ApplicantsStatusChanged>(_onStatusChanged);
  }

  final ApplicationRepository _repository;
  StreamSubscription<List<Application>>? _subscription;

  Future<void> _onSubscriptionRequested(
    ApplicantsSubscriptionRequested event,
    Emitter<ApplicantsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.applicantsForOpportunityStream(event.opportunityId).listen(
          (list) => add(ApplicantsUpdated(list)),
          onError: (error) => add(ApplicantsFailed(error.toString())),
        );
  }

  void _onUpdated(ApplicantsUpdated event, Emitter<ApplicantsState> emit) {
    final previous = state;
    emit(ApplicantsLoaded(
      applicants: event.applicants,
      processingIds: previous is ApplicantsLoaded ? previous.processingIds : const {},
    ));
  }

  void _onFailed(ApplicantsFailed event, Emitter<ApplicantsState> emit) {
    emit(ApplicantsError(event.message));
  }

  Future<void> _onStatusChanged(
    ApplicantsStatusChanged event,
    Emitter<ApplicantsState> emit,
  ) async {
    final current = state;
    if (current is! ApplicantsLoaded) return;
    emit(ApplicantsLoaded(
      applicants: current.applicants,
      processingIds: {...current.processingIds, event.applicationId},
    ));
    try {
      await _repository.updateStatus(event.applicationId, event.status);
    } catch (_) {
      final latest = state;
      if (latest is ApplicantsLoaded) {
        emit(ApplicantsLoaded(
          applicants: latest.applicants,
          processingIds: {...latest.processingIds}..remove(event.applicationId),
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
