import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/applications/bloc/applicants_bloc.dart';
import '../../features/applications/bloc/applicants_event.dart';
import '../../features/applications/bloc/applicants_state.dart';
import '../../features/applications/data/application_repository.dart';
import '../../features/applications/models/application.dart';
import '../../features/applications/models/application_status.dart';
import '../../features/opportunities/models/opportunity.dart';

class ApplicantsScreen extends StatelessWidget {
  final Opportunity opportunity;
  const ApplicantsScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApplicantsBloc(ApplicationRepository())
        ..add(ApplicantsSubscriptionRequested(opportunity.id)),
      child: Scaffold(
        appBar: AppBar(title: Text('Applicants — ${opportunity.title}')),
        body: const _ApplicantsBody(),
      ),
    );
  }
}

class _ApplicantsBody extends StatelessWidget {
  const _ApplicantsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplicantsBloc, ApplicantsState>(
      builder: (context, state) {
        if (state is ApplicantsLoading) return const LoadingView();
        if (state is ApplicantsError) return ErrorView(message: state.message);

        final loaded = state as ApplicantsLoaded;
        if (loaded.applicants.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No applicants yet',
            message: 'Students who apply to this posting will show up here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: loaded.applicants.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final application = loaded.applicants[index];
            final isProcessing = loaded.processingIds.contains(application.id);
            return _ApplicantCard(application: application, isProcessing: isProcessing);
          },
        );
      },
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Application application;
  final bool isProcessing;
  const _ApplicantCard({required this.application, required this.isProcessing});

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

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _statusColors(application.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(application.studentName, style: AppTextStyles.subtitle)),
                StatusBadge(label: application.status.label, foreground: fg, background: bg),
              ],
            ),
            const SizedBox(height: 12),
            if (isProcessing)
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                ),
              )
            else
              DropdownButtonFormField<ApplicationStatus>(
                initialValue: application.status,
                decoration: const InputDecoration(labelText: 'Update status'),
                items: ApplicationStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (status) {
                  if (status == null || status == application.status) return;
                  context.read<ApplicantsBloc>().add(
                        ApplicantsStatusChanged(applicationId: application.id, status: status),
                      );
                },
              ),
          ],
        ),
      ),
    );
  }
}
