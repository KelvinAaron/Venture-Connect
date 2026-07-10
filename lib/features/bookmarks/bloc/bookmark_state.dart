import 'package:equatable/equatable.dart';

class BookmarkState extends Equatable {
  final bool isLoading;
  final bool isBookmarked;

  const BookmarkState({this.isLoading = true, this.isBookmarked = false});

  @override
  List<Object?> get props => [isLoading, isBookmarked];
}
