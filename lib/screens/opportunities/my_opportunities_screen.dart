import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/opportunities/bloc/my_opportunities_bloc.dart';
import '../../features/opportunities/bloc/my_opportunities_event.dart';
import '../../features/opportunities/bloc/my_opportunities_state.dart';
import '../../features/opportunities/data/opportunity_repository.dart';
import '../../features/opportunities/models/opportunity.dart';
import '../../features/startup_profile/models/startup.dart';
import '../applications/applicants_screen.dart';
import 'post_opportunity_screen.dart';

/// Body-only widget embedded by StartupHomeScreen. Every posting owned by
/// this startup, open and closed alike, with edit/close/reopen actions and
/// a link into that posting's applicant list.
class MyOpportunitiesView extends StatelessWidget {
  final Startup startup;
  const MyOpportunitiesView({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyOpportunitiesBloc(OpportunityRepository())
        ..add(MyOpportunitiesSubscriptionRequested(startup.id)),
      child: _MyOpportunitiesBody(startup: startup),
    );
  }
}

class _MyOpportunitiesBody extends StatelessWidget {
  final Startup startup;
  const _MyOpportunitiesBody({required this.startup});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyOpportunitiesBloc, MyOpportunitiesState>(
      builder: (context, state) {
        if (state is MyOpportunitiesLoading) return const LoadingView();
        if (state is MyOpportunitiesError) return ErrorView(message: state.message);

        final loaded = state as MyOpportunitiesLoaded;
        if (loaded.opportunities.isEmpty) {
          return EmptyState(
            icon: Icons.post_add_outlined,
            title: 'No postings yet',
            message: 'Tap the + button to post your first opportunity.',
            action: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PostOpportunityScreen(startup: startup)),
              ),
              child: const Text('Post an opportunity'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: loaded.opportunities.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final opportunity = loaded.opportunities[index];
            final isProcessing = loaded.processingIds.contains(opportunity.id);
            return _MyOpportunityCard(
              opportunity: opportunity,
              startup: startup,
              isProcessing: isProcessing,
            );
          },
        );
      },
    );
  }
}

class _MyOpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final Startup startup;
  final bool isProcessing;

  const _MyOpportunityCard({
    required this.opportunity,
    required this.startup,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(opportunity.title, style: AppTextStyles.subtitle)),
                StatusBadge(
                  label: opportunity.isOpen ? 'Open' : 'Closed',
                  foreground: opportunity.isOpen ? AppColors.success : AppColors.textSecondary,
                  background: opportunity.isOpen ? AppColors.successBg : AppColors.background,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(opportunity.category, style: AppTextStyles.caption),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ApplicantsScreen(opportunity: opportunity),
                      ),
                    ),
                    child: const Text('View applicants'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            PostOpportunityScreen(startup: startup, existing: opportunity),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isProcessing)
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.primary),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.read<MyOpportunitiesBloc>().add(
                        MyOpportunitiesOpenToggled(
                          opportunityId: opportunity.id,
                          isOpen: !opportunity.isOpen,
                        ),
                      ),
                  child: Text(opportunity.isOpen ? 'Close posting' : 'Reopen posting'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
