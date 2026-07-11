import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';

/// Confirms with the user before actually logging out — used by every
/// logout button in the app so a stray tap can't sign someone out
/// mid-task.
Future<void> confirmAndLogOut(BuildContext context) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Log out?',
    message: "You'll need to sign in again to continue.",
    confirmLabel: 'Log out',
    destructive: true,
  );
  if (confirmed && context.mounted) {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }
}
