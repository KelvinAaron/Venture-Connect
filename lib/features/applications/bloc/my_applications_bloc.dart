import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/application_repository.dart';
import '../models/application.dart';
import 'my_applications_event.dart';
import 'my_applications_state.dart';

class MyApplicationsBloc extends Bloc<MyApplicationsEvent, MyApplicationsState> {
  MyApplicationsBloc(this._repository) : super(const MyApplicationsLoading()) {
    on<MyApplicationsSubscriptionRequested>(_onSubscriptionRequested);
    on<MyApplicationsUpdated>(_onUpdated);
    on<MyApplicationsFailed>(_onFailed);
  }

  final ApplicationRepository _repository;
  StreamSubscription<List<Application>>? _subscription;

  Future<void> _onSubscriptionRequested(
    MyApplicationsSubscriptionRequested event,
    Emitter<MyApplicationsState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.myApplicationsStream(event.studentUid).listen(
          (list) => add(MyApplicationsUpdated(list)),
          onError: (error) => add(MyApplicationsFailed(error.toString())),
        );
  }

  void _onUpdated(MyApplicationsUpdated event, Emitter<MyApplicationsState> emit) {
    emit(MyApplicationsLoaded(event.applications));
  }

  void _onFailed(MyApplicationsFailed event, Emitter<MyApplicationsState> emit) {
    emit(MyApplicationsError(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
