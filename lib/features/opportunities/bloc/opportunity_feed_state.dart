import 'package:equatable/equatable.dart';
import '../models/opportunity.dart';

enum OpportunityFeedStatus { loading, loaded, error }

/// Single state class (rather than a sealed hierarchy): the feed always
/// needs to remember the search/category filters even while loading or
/// erroring, and computing the filtered list as a getter here keeps that
/// logic in one place instead of re-deriving it in the widget.
class OpportunityFeedState extends Equatable {
  final OpportunityFeedStatus status;
  final List<Opportunity> all;
  final String query;
  final String? category;
  final String? errorMessage;

  const OpportunityFeedState({
    this.status = OpportunityFeedStatus.loading,
    this.all = const [],
    this.query = '',
    this.category,
    this.errorMessage,
  });

  List<Opportunity> get filtered {
    final normalizedQuery = query.trim().toLowerCase();
    return all.where((o) {
      final matchesCategory = category == null || o.category == category;
      final matchesQuery = normalizedQuery.isEmpty ||
          o.title.toLowerCase().contains(normalizedQuery) ||
          o.startupName.toLowerCase().contains(normalizedQuery) ||
          o.skillsRequired.any((s) => s.toLowerCase().contains(normalizedQuery));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  OpportunityFeedState copyWith({
    OpportunityFeedStatus? status,
    List<Opportunity>? all,
    String? query,
    String? Function()? category,
    String? errorMessage,
  }) {
    return OpportunityFeedState(
      status: status ?? this.status,
      all: all ?? this.all,
      query: query ?? this.query,
      category: category != null ? category() : this.category,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, all, query, category, errorMessage];
}
