import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/models/app_user.dart';
import '../../startup_profile/data/startup_repository.dart';
import '../../startup_profile/models/startup.dart';
import '../data/user_repository.dart';
import '../models/admin_user_row.dart';
import 'admin_users_event.dart';
import 'admin_users_state.dart';

/// Combines two independent Firestore streams (`users`, `startups`) into a
/// single live list of [AdminUserRow]. Firestore has no server-side join,
/// so this keeps the latest snapshot of each stream and recomputes the
/// merged list whenever either one emits.
class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  AdminUsersBloc(this._userRepository, this._startupRepository) : super(const AdminUsersLoading()) {
    on<AdminUsersSubscriptionRequested>(_onSubscriptionRequested);
    on<AdminUsersUsersUpdated>(_onUsersUpdated);
    on<AdminUsersStartupsUpdated>(_onStartupsUpdated);
    on<AdminUsersFailed>(_onFailed);
    on<AdminUsersStartupDecided>(_onStartupDecided);
  }

  final UserRepository _userRepository;
  final StartupRepository _startupRepository;
  StreamSubscription<List<AppUser>>? _usersSubscription;
  StreamSubscription<List<Startup>>? _startupsSubscription;

  List<AppUser> _latestUsers = [];
  List<Startup> _latestStartups = [];
  bool _hasUsers = false;
  bool _hasStartups = false;

  Future<void> _onSubscriptionRequested(
    AdminUsersSubscriptionRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    await _usersSubscription?.cancel();
    await _startupsSubscription?.cancel();
    _usersSubscription = _userRepository.allUsersStream().listen(
          (users) => add(AdminUsersUsersUpdated(users)),
          onError: (error) => add(AdminUsersFailed(error.toString())),
        );
    _startupsSubscription = _startupRepository.allStartupsStream().listen(
          (startups) => add(AdminUsersStartupsUpdated(startups)),
          onError: (error) => add(AdminUsersFailed(error.toString())),
        );
  }

  void _onUsersUpdated(AdminUsersUsersUpdated event, Emitter<AdminUsersState> emit) {
    _latestUsers = event.users;
    _hasUsers = true;
    _emitCombined(emit);
  }

  void _onStartupsUpdated(AdminUsersStartupsUpdated event, Emitter<AdminUsersState> emit) {
    _latestStartups = event.startups;
    _hasStartups = true;
    _emitCombined(emit);
  }

  void _emitCombined(Emitter<AdminUsersState> emit) {
    if (!_hasUsers || !_hasStartups) return;
    final startupsByOwner = {for (final s in _latestStartups) s.ownerUid: s};
    final rows = _latestUsers
        .map((u) => AdminUserRow(user: u, startup: startupsByOwner[u.uid]))
        .toList();
    // Don't carry processingStartupIds forward — see
    // MyOpportunitiesBloc._onUpdated for why: a fresh snapshot means the
    // write already resolved, so this is what actually clears the spinner.
    emit(AdminUsersLoaded(rows: rows));
  }

  void _onFailed(AdminUsersFailed event, Emitter<AdminUsersState> emit) {
    emit(AdminUsersError(event.message));
  }

  Future<void> _onStartupDecided(
    AdminUsersStartupDecided event,
    Emitter<AdminUsersState> emit,
  ) async {
    final current = state;
    if (current is! AdminUsersLoaded) return;
    emit(AdminUsersLoaded(
      rows: current.rows,
      processingStartupIds: {...current.processingStartupIds, event.startupId},
    ));
    try {
      await _startupRepository.decide(event.startupId, approve: event.approve);
      // success -> the startups stream listener emits refreshed rows
    } catch (_) {
      final latest = state;
      if (latest is AdminUsersLoaded) {
        emit(AdminUsersLoaded(
          rows: latest.rows,
          processingStartupIds: {...latest.processingStartupIds}..remove(event.startupId),
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _startupsSubscription?.cancel();
    return super.close();
  }
}
