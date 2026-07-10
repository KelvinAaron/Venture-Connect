import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/bookmarks/bloc/bookmark_cubit.dart';
import '../../features/bookmarks/bloc/bookmark_state.dart';
import '../../features/bookmarks/data/bookmark_repository.dart';

/// Reusable save/unsave toggle for an opportunity, used on both the feed
/// card and the detail screen. Renders nothing if no one is signed in
/// (shouldn't happen in practice — every route that shows this is
/// auth-gated — but keeps the widget safe to drop in anywhere).
class BookmarkButton extends StatelessWidget {
  final String opportunityId;
  const BookmarkButton({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => BookmarkCubit(
        BookmarkRepository(),
        uid: authState.user.uid,
        opportunityId: opportunityId,
      ),
      child: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          return IconButton(
            icon: Icon(
              state.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.primary,
            ),
            onPressed: state.isLoading ? null : () => context.read<BookmarkCubit>().toggle(),
          );
        },
      ),
    );
  }
}
