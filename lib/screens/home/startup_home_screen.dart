import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/startup_profile/models/startup.dart';
import '../opportunities/my_opportunities_screen.dart';
import '../opportunities/post_opportunity_screen.dart';

/// Rendered by StartupGate once the signed-in startup's profile is verified.
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
      body: MyOpportunitiesView(startup: startup),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostOpportunityScreen(startup: startup)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
