import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../features/startup_profile/bloc/admin_verification_bloc.dart';
import '../../features/startup_profile/bloc/admin_verification_event.dart';
import '../../features/startup_profile/bloc/admin_verification_state.dart';
import '../../features/startup_profile/data/startup_repository.dart';
import '../../features/startup_profile/models/startup.dart';

/// Body-only widget (no Scaffold) so it can be embedded by AdminHomeScreen.
/// Provides its own [AdminVerificationBloc] scoped to this screen's lifetime.
class AdminVerificationView extends StatelessWidget {
  const AdminVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminVerificationBloc(StartupRepository())
        ..add(const AdminVerificationSubscriptionRequested()),
      child: const _AdminVerificationBody(),
    );
  }
}

class _AdminVerificationBody extends StatelessWidget {
  const _AdminVerificationBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminVerificationBloc, AdminVerificationState>(
      builder: (context, state) {
        if (state is AdminVerificationLoading) return const LoadingView();
        if (state is AdminVerificationError) return ErrorView(message: state.message);

        final loaded = state as AdminVerificationLoaded;
        if (loaded.pending.isEmpty) {
          return const EmptyState(
            icon: Icons.verified_outlined,
            title: 'No pending startups',
            message: 'New startup sign-ups needing verification will show up here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: loaded.pending.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final startup = loaded.pending[index];
            final isProcessing = loaded.processingIds.contains(startup.id);
            return _PendingStartupCard(startup: startup, isProcessing: isProcessing);
          },
        );
      },
    );
  }
}

class _PendingStartupCard extends StatelessWidget {
  final Startup startup;
  final bool isProcessing;

  const _PendingStartupCard({required this.startup, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(startup.name, style: AppTextStyles.subtitle),
            const SizedBox(height: 4),
            Text(startup.category, style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Text(
              startup.description,
              style: AppTextStyles.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (startup.website.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(startup.website, style: AppTextStyles.bodyMuted),
            ],
            const SizedBox(height: 14),
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
                    onPressed: () => context.read<AdminVerificationBloc>().add(
                          AdminVerificationDecided(startupId: startup.id, approve: false),
                        ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.read<AdminVerificationBloc>().add(
                          AdminVerificationDecided(startupId: startup.id, approve: true),
                        ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
