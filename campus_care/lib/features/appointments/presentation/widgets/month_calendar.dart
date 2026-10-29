import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';

/// Monday-first month grid. Days that are not in [available] are struck through and
/// cannot be tapped (weekends, blocked days, fully booked days, the past).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.available,
    required this.selected,
    required this.onSelect,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.canGoPrev = true,
    this.canGoNext = true,
    this.loading = false,
  });

  /// First day of the month shown (UTC-flagged).
  final DateTime month;
  final Set<DateTime> available;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final bool canGoPrev;
  final bool canGoNext;
  final bool loading;

  static const _headers = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime.utc(month.year, month.month + 1, 0).day;
    final lead = month.weekday - 1; // blanks before the 1st (Monday first)
    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox(height: 44),
      for (var d = 1; d <= daysInMonth; d++) _dayCell(DateTime.utc(month.year, month.month, d)),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox(height: 44));
    }
    final rows = <Widget>[
      for (var i = 0; i < cells.length; i += 7)
        Row(children: [for (final c in cells.sublist(i, i + 7)) Expanded(child: c)]),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(70),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(130)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous month',
                onPressed: canGoPrev && !loading ? onPrevMonth : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${monthName(month.month)} ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                onPressed: canGoNext && !loading ? onNextMonth : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Row(
            children: [
              for (final h in _headers)
                Expanded(
                  child: Center(
                    child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Column(children: rows),
              if (loading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime day) {
    final enabled = !loading && available.contains(day);
    final isSelected = selected == day;
    final label = '${day.day} ${monthName(day.month)}';
    return Semantics(
      button: enabled,
      selected: isSelected,
      label: enabled ? '$label, available' : '$label, not available',
      child: ExcludeSemantics(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? () => onSelect(day) : null,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: isSelected
                ? const BoxDecoration(shape: BoxShape.circle, color: AppColors.navy)
                : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isSelected ? Colors.white : AppColors.navy.withAlpha(enabled ? 255 : 110),
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
