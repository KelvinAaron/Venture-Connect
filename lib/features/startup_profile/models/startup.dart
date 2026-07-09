import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'verification_status.dart';

class Startup extends Equatable {
  final String id; // == ownerUid, keeps a 1:1 owner-to-startup mapping
  final String ownerUid;
  final String name;
  final String description;
  final String category;
  final String website;
  final VerificationStatus status;
  final DateTime? createdAt;
  final DateTime? decidedAt;

  const Startup({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.category,
    required this.website,
    required this.status,
    this.createdAt,
    this.decidedAt,
  });

  bool get isVerified => status == VerificationStatus.verified;
  bool get isPending => status == VerificationStatus.pending;
  bool get isRejected => status == VerificationStatus.rejected;

  factory Startup.fromMap(String id, Map<String, dynamic> map) {
    return Startup(
      id: id,
      ownerUid: map['ownerUid'] as String? ?? id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Other',
      website: map['website'] as String? ?? '',
      status: VerificationStatusX.fromString(map['status'] as String? ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      decidedAt: (map['decidedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'ownerUid': ownerUid,
      'name': name,
      'description': description,
      'category': category,
      'website': website,
      'status': VerificationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  List<Object?> get props =>
      [id, ownerUid, name, description, category, website, status, createdAt, decidedAt];
}
