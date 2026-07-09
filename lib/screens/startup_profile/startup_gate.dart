import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_view.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/startup_profile/bloc/startup_profile_bloc.dart';
import '../../features/startup_profile/bloc/startup_profile_event.dart';
import '../../features/startup_profile/bloc/startup_profile_state.dart';
import '../../features/startup_profile/data/startup_repository.dart';
import '../home/startup_home_screen.dart';
import 'create_startup_profile_screen.dart';
import 'pending_approval_screen.dart';

/// Route target for `/startup`. Owns a [StartupProfileBloc] scoped to the
/// signed-in startup user's uid and renders whichever sub-screen matches
/// their current verification state, so go_router only needs one coarse
/// role route instead of separate routes per sub-state.
class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: LoadingView());
    }

    return BlocProvider(
      create: (_) => StartupProfileBloc(StartupRepository())
        ..add(StartupProfileSubscriptionRequested(authState.user.uid)),
      child: const _StartupGateBody(),
    );
  }
}

class _StartupGateBody extends StatelessWidget {
  const _StartupGateBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupProfileBloc, StartupProfileState>(
      builder: (context, state) {
        if (state is StartupProfileNotCreated) return const CreateStartupProfileScreen();
        if (state is StartupProfileAwaitingDecision) {
          return PendingApprovalScreen(startup: state.startup);
        }
        if (state is StartupProfileVerified) return StartupHomeScreen(startup: state.startup);
        return const Scaffold(body: LoadingView());
      },
    );
  }
}
