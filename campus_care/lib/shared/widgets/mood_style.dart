import 'package:flutter/material.dart';

/// Icon and colour for each of the 5 mood levels. The label is always shown too,
/// so colour is never the only signal.
class MoodStyle {
  const MoodStyle._();

  static IconData icon(int score) {
    switch (score) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_very_satisfied;
    }
  }

  static Color color(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFB8C00);
      case 3:
        return const Color(0xFFFDD835);
      case 4:
        return const Color(0xFF7CB342);
      default:
        return const Color(0xFF2E9E4F);
    }
  }
}
