import 'package:flutter/material.dart';
import '../auth/logout_confirmation.dart';
import '../startup_profile/admin_verification_screen.dart';
import '../user_management/admin_users_screen.dart';

// home screen for admins
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  static const _titles = ['Startup verifications', 'User management'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => confirmAndLogOut(context),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [AdminVerificationView(), AdminUsersView()],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), label: 'Verifications'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Users'),
        ],
      ),
    );
  }
}
