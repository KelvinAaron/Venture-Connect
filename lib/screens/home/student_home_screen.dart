import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';

/// Route target for `/student`. Placeholder body until Step 4 adds the
/// opportunity discovery feed here.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated ? authState.user.name : '';
    final firstName = name.trim().isEmpty ? 'there' : name.trim().split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $firstName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: InitialsAvatar(name: name, radius: 16),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.explore_outlined,
        title: 'Opportunities are coming soon',
        message: 'The discovery feed lands in the next build step.',
      ),
    );
  }
}
