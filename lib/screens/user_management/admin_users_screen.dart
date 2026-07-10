import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/startup_profile/data/startup_repository.dart';
import '../../features/startup_profile/models/verification_status.dart';
import '../../features/user_management/bloc/admin_users_bloc.dart';
import '../../features/user_management/bloc/admin_users_event.dart';
import '../../features/user_management/bloc/admin_users_state.dart';
import '../../features/user_management/data/user_repository.dart';
import '../../features/user_management/models/admin_user_row.dart';

/// Body-only widget (no Scaffold) so it can be embedded by AdminHomeScreen,
/// same pattern as AdminVerificationView. Lists every account in the
/// system; startup-role rows also get Approve/Reject controls so admins
/// don't have to leave this screen to manage verification.
class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminUsersBloc(UserRepository(), StartupRepository())
        ..add(const AdminUsersSubscriptionRequested()),
      child: const _AdminUsersBody(),
    );
  }
}

class _AdminUsersBody extends StatelessWidget {
  const _AdminUsersBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminUsersBloc, AdminUsersState>(
      builder: (context, state) {
        if (state is AdminUsersLoading) return const LoadingView();
        if (state is AdminUsersError) return ErrorView(message: state.message);

        final loaded = state as AdminUsersLoaded;
        if (loaded.rows.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No users yet',
            message: 'Everyone who signs up will show up here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: loaded.rows.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final row = loaded.rows[index];
            final isProcessing =
                row.startup != null && loaded.processingStartupIds.contains(row.startup!.id);
            return _UserRow(row: row, isProcessing: isProcessing);
          },
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  final AdminUserRow row;
  final bool isProcessing;

  const _UserRow({required this.row, required this.isProcessing});

  (Color, Color) _roleColors(UserRole role) {
    switch (role) {
      case UserRole.student:
        return (AppColors.info, AppColors.infoBg);
      case UserRole.startup:
        return (AppColors.primary, AppColors.primaryLight);
      case UserRole.admin:
        return (AppColors.accent, AppColors.accentLight);
    }
  }

  (Color, Color) _statusColors(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return (AppColors.warning, AppColors.warningBg);
      case VerificationStatus.verified:
        return (AppColors.success, AppColors.successBg);
      case VerificationStatus.rejected:
        return (AppColors.error, AppColors.errorBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = row.user;
    final startup = row.startup;
    final (roleFg, roleBg) = _roleColors(user.role);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(name: user.name.isEmpty ? user.email : user.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty ? user.email : user.name,
                        style: AppTextStyles.subtitle,
                      ),
                      Text(user.email, style: AppTextStyles.bodyMuted),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(label: user.role.label, foreground: roleFg, background: roleBg),
              ],
            ),
            if (startup != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(startup.name, style: AppTextStyles.subtitle),
                  ),
                  Builder(builder: (context) {
                    final (fg, bg) = _statusColors(startup.status);
                    return StatusBadge(
                      label: startup.status.name,
                      foreground: fg,
                      background: bg,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              if (isProcessing)
                const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () => context.read<AdminUsersBloc>().add(
                            AdminUsersStartupDecided(startupId: startup.id, approve: false),
                          ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.read<AdminUsersBloc>().add(
                            AdminUsersStartupDecided(startupId: startup.id, approve: true),
                          ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
