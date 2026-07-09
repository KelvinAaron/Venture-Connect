import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/startup_repository.dart';
import '../models/startup.dart';
import 'admin_verification_event.dart';
import 'admin_verification_state.dart';

class AdminVerificationBloc extends Bloc<AdminVerificationEvent, AdminVerificationState> {
  AdminVerificationBloc(this._repository) : super(const AdminVerificationLoading()) {
    on<AdminVerificationSubscriptionRequested>(_onSubscriptionRequested);
    on<AdminVerificationListUpdated>(_onListUpdated);
    on<AdminVerificationFailed>(_onFailed);
    on<AdminVerificationDecided>(_onDecided);
  }

  final StartupRepository _repository;
  StreamSubscription<List<Startup>>? _subscription;

  Future<void> _onSubscriptionRequested(
    AdminVerificationSubscriptionRequested event,
    Emitter<AdminVerificationState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.pendingStartupsStream().listen(
          (list) => add(AdminVerificationListUpdated(list)),
          onError: (error) => add(AdminVerificationFailed(error.toString())),
        );
  }

  void _onListUpdated(AdminVerificationListUpdated event, Emitter<AdminVerificationState> emit) {
    emit(AdminVerificationLoaded(pending: event.startups));
  }

  void _onFailed(AdminVerificationFailed event, Emitter<AdminVerificationState> emit) {
    emit(AdminVerificationError(event.message));
  }

  Future<void> _onDecided(
    AdminVerificationDecided event,
    Emitter<AdminVerificationState> emit,
  ) async {
    final current = state;
    if (current is! AdminVerificationLoaded) return;
    emit(AdminVerificationLoaded(
      pending: current.pending,
      processingIds: {...current.processingIds, event.startupId},
    ));
    try {
      await _repository.decide(event.startupId, approve: event.approve);
      // success -> the stream listener emits the refreshed list; the
      // decided startup drops out of pendingStartupsStream automatically.
    } catch (_) {
      final latest = state;
      if (latest is AdminVerificationLoaded) {
        emit(AdminVerificationLoaded(
          pending: latest.pending,
          processingIds: {...latest.processingIds}..remove(event.startupId),
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
