class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$');

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  /// Deliberately lenient (just "not empty") — used on the *login* form.
  /// Accounts created before [strongPassword] existed, or via Google, may
  /// not satisfy today's complexity rules; login shouldn't block on a
  /// client-side rule the account's real password predates. Firebase Auth
  /// itself is still the source of truth on whether the password is right.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  /// Used on the *signup* form only.
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must include at least one uppercase letter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }
}
