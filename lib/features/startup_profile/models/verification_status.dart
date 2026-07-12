// startup profile starts pending on creation admin verifies
enum VerificationStatus { pending, verified, rejected }

extension VerificationStatusX on VerificationStatus {
  static VerificationStatus fromString(String value) {
    return VerificationStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}
