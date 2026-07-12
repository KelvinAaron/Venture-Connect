import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/application_repository.dart';
import '../models/application.dart';
import '../../opportunities/models/opportunity.dart';
import 'apply_state.dart';

class ApplyCubit extends Cubit<ApplyState> {
  ApplyCubit(
    this._repository, {
    required this.opportunity,
    required this.studentUid,
    required this.studentName,
  }) : super(const ApplyLoading()) {
    _subscription = _repository.applicationStream(opportunity.id, studentUid).listen(
          (application) => emit(application == null ? const ApplyNotApplied() : ApplyApplied(application)),
        );
  }

  final ApplicationRepository _repository;
  final Opportunity opportunity;
  final String studentUid;
  final String studentName;
  late final StreamSubscription<Application?> _subscription;

  Future<void> apply({Map<String, String> answers = const {}}) async {
    if (state is! ApplyNotApplied) return;
    emit(const ApplyInProgress());
    try {
      await _repository.apply(
        opportunityId: opportunity.id,
        opportunityTitle: opportunity.title,
        startupId: opportunity.startupId,
        startupName: opportunity.startupName,
        studentUid: studentUid,
        studentName: studentName,
        answers: answers,
      );
      // success -> the stream subscription emits ApplyApplied
    } catch (e) {
      emit(ApplyError(e.toString()));
      emit(const ApplyNotApplied());
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
