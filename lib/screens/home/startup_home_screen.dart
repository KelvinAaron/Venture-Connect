import 'package:flutter/material.dart';
import '../../features/startup_profile/models/startup.dart';
import '../notifications/notification_bell.dart';
import '../opportunities/my_opportunities_screen.dart';
import '../opportunities/post_opportunity_screen.dart';
import '../profile/startup_profile_screen.dart';

/// Rendered by StartupGate once the signed-in startup's profile is
/// verified. Two tabs — postings and profile — mounted via IndexedStack.
class StartupHomeScreen extends StatefulWidget {
  final Startup startup;
  const StartupHomeScreen({super.key, required this.startup});

  @override
  State<StartupHomeScreen> createState() => _StartupHomeScreenState();
}

class _StartupHomeScreenState extends State<StartupHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final titles = [widget.startup.name, 'Startup profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: const [NotificationBell()],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: [
            MyOpportunitiesView(startup: widget.startup),
            StartupProfileView(startup: widget.startup),
          ],
        ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PostOpportunityScreen(startup: widget.startup),
                ),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.post_add_outlined), label: 'Postings'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
