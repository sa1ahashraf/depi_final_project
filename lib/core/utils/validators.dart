class AppValidators {
  AppValidators._();

  static String? required(String? value, {String message = 'هذا الحقل مطلوب'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'أدخل بريداً إلكترونياً صحيحاً';
    }
    return null;
  }

  static String? egyptianPhone(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^(?:\+20|0020|0)?1[0125]\d{8}$')
        .hasMatch(value!.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'أدخل رقم هاتف مصري صحيحاً';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.length < 8) {
      return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = required(value);
    if (requiredError != null) {
      return requiredError;
    }
    return value == password ? null : 'كلمتا المرور غير متطابقتين';
  }
}
