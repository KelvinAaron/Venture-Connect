import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Opportunity extends Equatable {
  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final List<String> skillsRequired;
  final String commitment;
  final String location;
  final bool isOpen;
  final DateTime? createdAt;

  /// Short-answer questions a startup wants applicants to answer, shown to
  /// students on the Apply flow and answered per-application.
  final List<String> customQuestions;

  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.skillsRequired,
    required this.commitment,
    required this.location,
    required this.isOpen,
    this.customQuestions = const [],
    this.createdAt,
  });

  factory Opportunity.fromMap(String id, Map<String, dynamic> map) {
    return Opportunity(
      id: id,
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      skillsRequired: List<String>.from(map['skillsRequired'] as List? ?? const []),
      commitment: map['commitment'] as String? ?? '',
      location: map['location'] as String? ?? '',
      isOpen: map['isOpen'] as bool? ?? true,
      customQuestions: List<String>.from(map['customQuestions'] as List? ?? const []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'category': category,
      'skillsRequired': skillsRequired,
      'commitment': commitment,
      'location': location,
      'isOpen': true,
      'customQuestions': customQuestions,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'skillsRequired': skillsRequired,
      'commitment': commitment,
      'location': location,
      'customQuestions': customQuestions,
    };
  }

  @override
  List<Object?> get props => [
        id,
        startupId,
        startupName,
        title,
        description,
        category,
        skillsRequired,
        commitment,
        location,
        isOpen,
        customQuestions,
        createdAt,
      ];
}
