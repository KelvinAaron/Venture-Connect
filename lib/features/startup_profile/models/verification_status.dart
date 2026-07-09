/// A startup profile starts `pending` on creation. An admin then decides,
/// moving it to `verified` (unlocks opportunity posting) or `rejected`.
enum VerificationStatus { pending, verified, rejected }

extension VerificationStatusX on VerificationStatus {
  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}
