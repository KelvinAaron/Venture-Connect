enum ApplicationStatus { applied, underReview, interview, accepted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ApplicationStatus.applied,
    );
  }

  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
