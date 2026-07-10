import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../features/bookmarks/bloc/saved_opportunities_bloc.dart';
import '../../features/bookmarks/bloc/saved_opportunities_event.dart';
import '../../features/bookmarks/bloc/saved_opportunities_state.dart';
import '../../features/bookmarks/data/bookmark_repository.dart';
import '../../features/opportunities/data/opportunity_repository.dart';
import '../../features/opportunities/models/opportunity.dart';
import '../opportunities/opportunity_detail_screen.dart';
import 'bookmark_button.dart';

/// Body-only widget embedded by StudentHomeScreen's "Saved" tab.
class SavedOpportunitiesView extends StatelessWidget {
  final String studentUid;
  const SavedOpportunitiesView({super.key, required this.studentUid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedOpportunitiesBloc(BookmarkRepository(), OpportunityRepository())
        ..add(SavedOpportunitiesSubscriptionRequested(studentUid)),
      child: const _SavedOpportunitiesBody(),
    );
  }
}

class _SavedOpportunitiesBody extends StatelessWidget {
  const _SavedOpportunitiesBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedOpportunitiesBloc, SavedOpportunitiesState>(
      builder: (context, state) {
        if (state is SavedOpportunitiesLoading) return const LoadingView();
        if (state is SavedOpportunitiesError) return ErrorView(message: state.message);

        final saved = (state as SavedOpportunitiesLoaded).opportunities;
        if (saved.isEmpty) {
          return const EmptyState(
            icon: Icons.bookmark_border,
            title: 'Nothing saved yet',
            message: 'Tap the bookmark icon on any opportunity to save it for later.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: saved.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SavedCard(opportunity: saved[index]),
        );
      },
    );
  }
}

class _SavedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _SavedCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opportunity)),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title, style: AppTextStyles.subtitle),
                    const SizedBox(height: 2),
                    Text(opportunity.startupName, style: AppTextStyles.bodyMuted),
                    const SizedBox(height: 8),
                    if (!opportunity.isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Text('Closed', style: AppTextStyles.caption),
                      ),
                  ],
                ),
              ),
              BookmarkButton(opportunityId: opportunity.id),
            ],
          ),
        ),
      ),
    );
  }
}
