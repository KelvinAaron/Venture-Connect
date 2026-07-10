import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'application_status.dart';

class Application extends Equatable {
  final String id; // '${opportunityId}_$studentUid' — one application per student per posting
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentUid;
  final String studentName;
  final ApplicationStatus status;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentUid,
    required this.studentName,
    required this.status,
    this.appliedAt,
    this.updatedAt,
  });

  factory Application.fromMap(String id, Map<String, dynamic> map) {
    return Application(
      id: id,
      opportunityId: map['opportunityId'] as String? ?? '',
      opportunityTitle: map['opportunityTitle'] as String? ?? '',
      startupId: map['startupId'] as String? ?? '',
      startupName: map['startupName'] as String? ?? '',
      studentUid: map['studentUid'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      status: ApplicationStatusX.fromString(map['status'] as String? ?? 'applied'),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentUid': studentUid,
      'studentName': studentName,
      'status': ApplicationStatus.applied.name,
      'appliedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        opportunityId,
        opportunityTitle,
        startupId,
        startupName,
        studentUid,
        studentName,
        status,
        appliedAt,
        updatedAt,
      ];
}
