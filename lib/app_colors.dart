import 'package:flutter/material.dart';

class AppColors {
  static Color correctBackground = Colors.green.shade800;
  static Color incorrectBackground = Colors.red.shade800;

  static Color? getTileColor({
    required bool isVerifying,
    required bool isCorrect,
    required bool isSelected,
  }) {
    if (isVerifying) {
      return isCorrect
          ? correctBackground
          : (isSelected ? incorrectBackground : null);
    }
    return null;
  }
}
