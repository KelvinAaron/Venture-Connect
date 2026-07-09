import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/startup_repository.dart';
import '../models/startup.dart';
import 'startup_profile_event.dart';
import 'startup_profile_state.dart';

class StartupProfileBloc extends Bloc<StartupProfileEvent, StartupProfileState> {
  StartupProfileBloc(this._repository) : super(const StartupProfileLoading()) {
    on<StartupProfileSubscriptionRequested>(_onSubscriptionRequested);
    on<StartupProfileUpdated>(_onUpdated);
    on<StartupProfileSubmitted>(_onSubmitted);
  }

  final StartupRepository _repository;
  StreamSubscription<Startup?>? _subscription;
  String? _ownerUid;

  Future<void> _onSubscriptionRequested(
    StartupProfileSubscriptionRequested event,
    Emitter<StartupProfileState> emit,
  ) async {
    _ownerUid = event.ownerUid;
    await _subscription?.cancel();
    _subscription = _repository.myStartupStream(event.ownerUid).listen(
          (startup) => add(StartupProfileUpdated(startup)),
          onError: (_) => add(const StartupProfileUpdated(null)),
        );
  }

  void _onUpdated(StartupProfileUpdated event, Emitter<StartupProfileState> emit) {
    final startup = event.startup;
    if (startup == null) {
      emit(const StartupProfileNotCreated());
    } else if (startup.isVerified) {
      emit(StartupProfileVerified(startup));
    } else {
      emit(StartupProfileAwaitingDecision(startup));
    }
  }

  Future<void> _onSubmitted(
    StartupProfileSubmitted event,
    Emitter<StartupProfileState> emit,
  ) async {
    final ownerUid = _ownerUid;
    if (ownerUid == null) return;
    emit(const StartupProfileNotCreated(isSubmitting: true));
    try {
      await _repository.createProfile(
        ownerUid: ownerUid,
        name: event.name,
        description: event.description,
        category: event.category,
        website: event.website,
      );
      // success -> the stream subscription emits StartupProfileAwaitingDecision
    } catch (e) {
      emit(StartupProfileNotCreated(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
