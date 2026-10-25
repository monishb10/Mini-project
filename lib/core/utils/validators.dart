class Validators {
  Validators._();

  static String? required(
    String? value, [
    String message = 'This field is required',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll / Student ID is required';
    }
    if (value.trim().length < 4) {
      return 'Roll ID must be at least 4 characters';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? customMessage]) {
    if (value == null || value.length < min) {
      return customMessage ?? 'Must be at least $min characters';
    }
    return null;
  }

  static String? positiveNumber(
    String? value, [
    String message = 'Must be a valid positive number',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    final num = int.tryParse(value.trim());
    if (num == null || num <= 0) {
      return message;
    }
    return null;
  }
}
