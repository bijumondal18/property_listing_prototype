class Validators {
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value, fieldName: 'Email');
    if (requiredError != null) return requiredError;

    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final requiredError = required(value, fieldName: 'Password');
    if (requiredError != null) return requiredError;

    if (value!.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? signupPassword(String? value) {
    return password(value, minLength: 8);
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = required(value, fieldName: 'Confirm password');
    if (requiredError != null) return requiredError;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = required(value, fieldName: 'Mobile number');
    if (requiredError != null) return requiredError;

    final cleaned = value!.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Mobile number must be numeric';
    }

    String digits = cleaned;
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.length != 10) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  static String? name(String? value) {
    final requiredError = required(value, fieldName: 'Full name');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? propertyName(String? value) {
    final requiredError = required(value, fieldName: 'Property name');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 3) {
      return 'Property name must be at least 3 characters';
    }
    return null;
  }

  static String? location(String? value) {
    final requiredError = required(value, fieldName: 'Location');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = 'Value'}) {
    final requiredError = required(value, fieldName: fieldName);
    if (requiredError != null) return requiredError;
    final parsed = double.tryParse(value!.trim());
    if (parsed == null) {
      return '$fieldName must be numeric';
    }
    if (parsed <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }

  static String? description(String? value) {
    final requiredError = required(value, fieldName: 'Description');
    if (requiredError != null) return requiredError;
    if (value!.trim().length < 20) {
      return 'Description must be at least 20 characters';
    }
    return null;
  }

  static String? dropdownRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
