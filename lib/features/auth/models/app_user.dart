import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final List<String> skills;
  final List<String> interests;
  final String bio;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
    this.interests = const [],
    this.bio = '',
    this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRoleX.fromString(map['role'] as String? ?? 'student'),
      skills: List<String>.from(map['skills'] as List? ?? const []),
      interests: List<String>.from(map['interests'] as List? ?? const []),
      bio: map['bio'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  AppUser copyWith({
    String? name,
    List<String>? skills,
    List<String>? interests,
    String? bio,
  }) {
    return AppUser(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, name, email, role, skills, interests, bio, createdAt];
}
