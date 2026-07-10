import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/applications/bloc/my_applications_bloc.dart';
import '../../features/applications/bloc/my_applications_event.dart';
import '../../features/applications/bloc/my_applications_state.dart';
import '../../features/applications/data/application_repository.dart';
import '../../features/applications/models/application.dart';
import '../../features/applications/models/application_status.dart';

/// Body-only widget embedded by StudentHomeScreen's "Applications" tab.
class MyApplicationsView extends StatelessWidget {
  final String studentUid;
  const MyApplicationsView({super.key, required this.studentUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyApplicationsBloc(ApplicationRepository())
        ..add(MyApplicationsSubscriptionRequested(studentUid)),
      child: const _MyApplicationsBody(),
    );
  }
}

class _MyApplicationsBody extends StatelessWidget {
  const _MyApplicationsBody();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Applied'),
              Tab(text: 'Interview'),
              Tab(text: 'Accepted'),
              Tab(text: 'All'),
            ],
          ),
          Expanded(
            child: BlocBuilder<MyApplicationsBloc, MyApplicationsState>(
              builder: (context, state) {
                if (state is MyApplicationsLoading) return const LoadingView();
                if (state is MyApplicationsError) return ErrorView(message: state.message);

                final all = (state as MyApplicationsLoaded).applications;
                return TabBarView(
                  children: [
                    _ApplicationList(
                      applications:
                          all.where((a) => a.status == ApplicationStatus.applied).toList(),
                    ),
                    _ApplicationList(
                      applications:
                          all.where((a) => a.status == ApplicationStatus.interview).toList(),
                    ),
                    _ApplicationList(
                      applications:
                          all.where((a) => a.status == ApplicationStatus.accepted).toList(),
                    ),
                    _ApplicationList(applications: all),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationList extends StatelessWidget {
  final List<Application> applications;
  const _ApplicationList({required this.applications});

  @override
  Widget build(BuildContext context) {
    if (applications.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Nothing here yet',
        message: 'Applications matching this tab will show up here.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _ApplicationCard(application: applications[index]),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;
  const _ApplicationCard({required this.application});

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.opportunityTitle, style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(application.startupName, style: AppTextStyles.bodyMuted),
                  const SizedBox(height: 6),
                  Text(
                    'Applied ${DateFormatter.relative(application.appliedAt)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(label: application.status.label, foreground: fg, background: bg),
          ],
        ),
      ),
    );
  }
}
