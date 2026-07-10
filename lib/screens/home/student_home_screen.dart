import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../applications/my_applications_screen.dart';
import '../opportunities/opportunity_feed_screen.dart';

/// Route target for `/student`. Two tabs: opportunity discovery and this
/// student's own applications. Both stay mounted via IndexedStack so
/// switching tabs doesn't re-subscribe their Firestore streams.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final name = authState.user.name;
    final firstName = name.trim().isEmpty ? 'there' : name.trim().split(' ').first;
    final titles = ['Hello, $firstName', 'My Applications'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          const OpportunityFeedView(),
          MyApplicationsView(studentUid: authState.user.uid),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
        ],
      ),
    );
  }
}
