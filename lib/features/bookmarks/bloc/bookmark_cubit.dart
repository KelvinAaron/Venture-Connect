import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/bookmark_repository.dart';
import 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  BookmarkCubit(this._repository, {required this.uid, required this.opportunityId})
      : super(const BookmarkState()) {
    _subscription = _repository.isBookmarkedStream(uid, opportunityId).listen(
          (isBookmarked) => emit(BookmarkState(isLoading: false, isBookmarked: isBookmarked)),
        );
  }

  final BookmarkRepository _repository;
  final String uid;
  final String opportunityId;
  late final StreamSubscription<bool> _subscription;

  Future<void> toggle() {
    return _repository.setBookmarked(uid, opportunityId, !state.isBookmarked);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
