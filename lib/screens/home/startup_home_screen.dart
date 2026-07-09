import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/empty_state.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/startup_profile/models/startup.dart';

/// Rendered by StartupGate once the signed-in startup's profile is
/// verified. Placeholder body until Step 4 adds opportunity posting here.
class StartupHomeScreen extends StatelessWidget {
  final Startup startup;
  const StartupHomeScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(startup.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.post_add_outlined,
        title: 'Posting opportunities is coming soon',
        message: "You're verified — opportunity posting lands in the next build step.",
      ),
    );
  }
}
