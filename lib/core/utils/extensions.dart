import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  double get width => MediaQuery.of(this).width;
  double get height => MediaQuery.of(this).height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isSmall => width < 360;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

extension StringX on String {
  bool get isValidPhone =>
      RegExp(r'^07\d{8}$').hasMatch(replaceAll(RegExp(r'\s'), ''));

  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(this);

  String get toArabicNumbers {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var result = this;
    for (int i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], western[i]);
    }
    return result;
  }
}

extension IntX on int {
  String get toArabicOrdinal {
    const ordinals = [
      'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس',
      'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر'
    ];
    if (this >= 1 && this <= 10) return ordinals[this - 1];
    return 'الـ$this';
  }
}

extension DoubleX on double {
  String get toPercentage => '${(this * 100).toStringAsFixed(1)}%';

  Color get toAttendanceColor {
    if (this >= 0.9) return AppColors.present;
    if (this >= 0.75) return AppColors.accent;
    return AppColors.absent;
  }

  Color get toGradeColor {
    if (this >= 90) return AppColors.present;
    if (this >= 75) return AppColors.accent;
    if (this >= 60) return const Color(0xFF2196F3);
    return AppColors.absent;
  }
}
