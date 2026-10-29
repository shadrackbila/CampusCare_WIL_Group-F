import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/mood_style.dart';
import '../../models/weekly_mood.dart';

/// Line chart of the average mood (1-5) for each of the last 4 weeks.
class MoodChart extends StatelessWidget {
  const MoodChart({super.key, required this.weeks});

  final List<WeeklyMood> weeks;

  String get _summary {
    final parts = [
      for (final w in weeks)
        if (w.avgMood != null)
          'week of ${shortDate(w.weekStart)}: average ${w.avgMood!.toStringAsFixed(1)} out of 5',
    ];
    return parts.isEmpty
        ? 'Mood chart. No check-ins in the last 4 weeks.'
        : 'Mood chart. ${parts.join('; ')}.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _summary,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 190,
          width: double.infinity,
          child: CustomPaint(painter: _MoodChartPainter(weeks)),
        ),
      ),
    );
  }
}

class _MoodChartPainter extends CustomPainter {
  _MoodChartPainter(this.weeks);

  final List<WeeklyMood> weeks;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 26.0, right = 8.0, top = 10.0, bottom = 26.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    double yFor(double v) => top + h - (v - 1) / 4 * h;
    final n = weeks.length;
    double xFor(int i) => left + w * (i + 0.5) / n;

    final grid = Paint()
      ..color = AppColors.navy.withAlpha(60)
      ..strokeWidth = 1;
    for (var v = 1; v <= 5; v++) {
      final y = yFor(v.toDouble());
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
      _text(canvas, '$v', Offset(4, y - 7), 12);
    }
    for (var i = 0; i < n; i++) {
      _text(
        canvas,
        shortDate(weeks[i].weekStart),
        Offset(xFor(i) - 18, size.height - 18),
        11,
      );
    }

    final points = <Offset>[];
    final scores = <double>[];
    for (var i = 0; i < n; i++) {
      final v = weeks[i].avgMood;
      if (v != null) {
        points.add(Offset(xFor(i), yFor(v.clamp(1, 5).toDouble())));
        scores.add(v);
      }
    }
    if (points.length > 1) {
      final line = Paint()
        ..color = AppColors.navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, line);
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 7, Paint()..color = Colors.white);
      canvas.drawCircle(
        points[i],
        5,
        Paint()..color = MoodStyle.color(scores[i].round()),
      );
    }
  }

  void _text(Canvas canvas, String s, Offset at, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: AppColors.navy, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant _MoodChartPainter old) => old.weeks != weeks;
}
