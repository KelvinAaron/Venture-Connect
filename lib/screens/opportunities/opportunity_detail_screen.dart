import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/applications/bloc/apply_cubit.dart';
import '../../features/applications/bloc/apply_state.dart';
import '../../features/applications/data/application_repository.dart';
import '../../features/applications/models/application_status.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/opportunities/models/opportunity.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isStudent = authState is AuthAuthenticated && authState.user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('Opportunity details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opportunity.title, style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text(opportunity.startupName, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(opportunity.category),
                  if (opportunity.commitment.isNotEmpty) _Tag(opportunity.commitment),
                  if (opportunity.location.isNotEmpty) _Tag(opportunity.location),
                  _Tag('Posted ${DateFormatter.relative(opportunity.createdAt)}'),
                ],
              ),
              const SizedBox(height: 24),
              Text('About', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(opportunity.description, style: AppTextStyles.body),
              if (opportunity.skillsRequired.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Skills required', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.skillsRequired.map((s) => _Tag(s)).toList(),
                ),
              ],
              if (isStudent) ...[
                const SizedBox(height: 32),
                _ApplySection(
                  opportunity: opportunity,
                  studentUid: authState.user.uid,
                  studentName: authState.user.name,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplySection extends StatelessWidget {
  final Opportunity opportunity;
  final String studentUid;
  final String studentName;

  const _ApplySection({
    required this.opportunity,
    required this.studentUid,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApplyCubit(
        ApplicationRepository(),
        opportunity: opportunity,
        studentUid: studentUid,
        studentName: studentName,
      ),
      child: BlocConsumer<ApplyCubit, ApplyState>(
        listener: (context, state) {
          if (state is ApplyError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ApplyLoading) {
            return const SizedBox(
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                ),
              ),
            );
          }
          if (state is ApplyApplied) {
            final (fg, bg) = _statusColors(state.application.status);
            return Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                const SizedBox(width: 8),
                const Text('You applied — status:', style: AppTextStyles.body),
                const SizedBox(width: 8),
                StatusBadge(label: state.application.status.label, foreground: fg, background: bg),
              ],
            );
          }
          return PrimaryButton(
            label: 'Apply now',
            isLoading: state is ApplyInProgress,
            onPressed: () => context.read<ApplyCubit>().apply(),
          );
        },
      ),
    );
  }

  (Color, Color) _statusColors(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return (AppColors.info, AppColors.infoBg);
      case ApplicationStatus.underReview:
        return (AppColors.warning, AppColors.warningBg);
      case ApplicationStatus.interview:
        return (AppColors.accent, AppColors.accentLight);
      case ApplicationStatus.accepted:
        return (AppColors.success, AppColors.successBg);
      case ApplicationStatus.rejected:
        return (AppColors.error, AppColors.errorBg);
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}
