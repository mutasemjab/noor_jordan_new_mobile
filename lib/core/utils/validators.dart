class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^07\d{8}$').hasMatch(cleaned)) {
      return 'يجب أن يكون رقم الهاتف 10 أرقام ويبدأ بـ 07';
    }
    return null;
  }

  static String? validateNationalId(String? value) {
    if (value == null || value.isEmpty) return 'الرقم الوطني مطلوب';
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{5,15}$').hasMatch(cleaned)) {
      return 'الرقم الوطني غير صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName مطلوب';
    return null;
  }

  static String? validateScore(String? value, {double maxScore = 100}) {
    if (value == null || value.isEmpty) return 'العلامة مطلوبة';
    final score = double.tryParse(value);
    if (score == null) return 'يجب أن تكون العلامة رقماً';
    if (score < 0) return 'العلامة لا يمكن أن تكون سالبة';
    if (score > maxScore) return 'العلامة لا يمكن أن تتجاوز $maxScore';
    return null;
  }
}
