import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../features/opportunities/bloc/opportunity_feed_bloc.dart';
import '../../features/opportunities/bloc/opportunity_feed_event.dart';
import '../../features/opportunities/bloc/opportunity_feed_state.dart';
import '../../features/opportunities/data/opportunity_repository.dart';
import '../../features/opportunities/models/opportunity.dart';
import '../bookmarks/bookmark_button.dart';
import 'opportunity_detail_screen.dart';

/// Body-only widget embedded by StudentHomeScreen's "Discover" tab.
class OpportunityFeedView extends StatelessWidget {
  const OpportunityFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OpportunityFeedBloc(OpportunityRepository())
        ..add(const OpportunityFeedSubscriptionRequested()),
      child: const _OpportunityFeedBody(),
    );
  }
}

class _OpportunityFeedBody extends StatefulWidget {
  const _OpportunityFeedBody();

  @override
  State<_OpportunityFeedBody> createState() => _OpportunityFeedBodyState();
}

class _OpportunityFeedBodyState extends State<_OpportunityFeedBody> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) =>
                context.read<OpportunityFeedBloc>().add(OpportunityFeedSearchChanged(value)),
            decoration: const InputDecoration(
              hintText: 'Search opportunities...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: BlocBuilder<OpportunityFeedBloc, OpportunityFeedState>(
            buildWhen: (previous, current) => previous.category != current.category,
            builder: (context, state) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: state.category == null,
                    onTap: () => context
                        .read<OpportunityFeedBloc>()
                        .add(const OpportunityFeedCategoryChanged(null)),
                  ),
                  const SizedBox(width: 8),
                  ...kCategories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: c,
                        selected: state.category == c,
                        onTap: () => context
                            .read<OpportunityFeedBloc>()
                            .add(OpportunityFeedCategoryChanged(c)),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<OpportunityFeedBloc, OpportunityFeedState>(
            builder: (context, state) {
              if (state.status == OpportunityFeedStatus.loading) return const LoadingView();
              if (state.status == OpportunityFeedStatus.error) {
                return ErrorView(message: state.errorMessage ?? 'Something went wrong.');
              }
              final results = state.filtered;
              if (results.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No opportunities found',
                  message: 'Try a different search term or category.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _OpportunityCard(opportunity: results[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(opportunity.title, style: AppTextStyles.subtitle)),
                  BookmarkButton(opportunityId: opportunity.id),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(opportunity.startupName, style: AppTextStyles.bodyMuted),
                  ),
                  Text(
                    DateFormatter.relative(opportunity.createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(opportunity.category),
                  if (opportunity.commitment.isNotEmpty)
                    _Tag('${opportunity.commitment} hrs/week'),
                  if (opportunity.location.isNotEmpty) _Tag(opportunity.location),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
