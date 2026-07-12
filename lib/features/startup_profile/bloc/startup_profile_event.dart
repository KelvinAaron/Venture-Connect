import 'package:equatable/equatable.dart';
import '../models/startup.dart';

sealed class StartupProfileEvent extends Equatable {
  const StartupProfileEvent();
  @override
  List<Object?> get props => [];
}

class StartupProfileSubscriptionRequested extends StartupProfileEvent {
  final String ownerUid;
  const StartupProfileSubscriptionRequested(this.ownerUid);
  @override
  List<Object?> get props => [ownerUid];
}

// Internal event fired whenever the Firestore stream emits.
class StartupProfileUpdated extends StartupProfileEvent {
  final Startup? startup;
  const StartupProfileUpdated(this.startup);
  @override
  List<Object?> get props => [startup];
}

class StartupProfileSubmitted extends StartupProfileEvent {
  final String name;
  final String description;
  final String category;
  final String website;
  const StartupProfileSubmitted({
    required this.name,
    required this.description,
    required this.category,
    required this.website,
  });
  @override
  List<Object?> get props => [name, description, category, website];
}
