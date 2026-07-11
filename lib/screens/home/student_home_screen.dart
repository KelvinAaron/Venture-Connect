import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../applications/my_applications_screen.dart';
import '../bookmarks/saved_opportunities_screen.dart';
import '../notifications/notification_bell.dart';
import '../opportunities/opportunity_feed_screen.dart';
import '../profile/my_profile_screen.dart';

/// Route target for `/student`. Four tabs, all mounted via IndexedStack so
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
    final titles = ['Hello, $firstName', 'My Applications', 'Saved', 'My Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: const [NotificationBell()],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            const OpportunityFeedView(),
            MyApplicationsView(studentUid: authState.user.uid),
            SavedOpportunitiesView(studentUid: authState.user.uid),
            MyProfileView(uid: authState.user.uid),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
