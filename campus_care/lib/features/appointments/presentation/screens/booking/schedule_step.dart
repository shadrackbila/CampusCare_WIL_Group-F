import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/date_format.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/error_banner.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../viewModels/booking_provider.dart';
import '../../widgets/booking_stepper.dart';
import '../../widgets/month_calendar.dart';

class ScheduleStep extends StatelessWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final date = p.selectedDate;
    final who = p.practitioner?.displayName;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BookingStepper(step: 2),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'You can book up to 3 weeks ahead.',
              style: TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available slots',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      who == null
                          ? 'Choose a date and time that works for you.'
                          : 'With $who. Choose a date and time that works for you.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (p.scheduleError != null) ...[
            ErrorBanner(p.scheduleError!),
            TextButton(
              onPressed: () {
                final b = context.read<BookingProvider>();
                b.reloadMonth();
                if (b.selectedDate != null) b.reloadSlots();
              },
              child: const Text('Try again'),
            ),
          ],
          MonthCalendar(
            month: p.month,
            available: p.availableDates,
            selected: date,
            loading: p.loadingDates,
            canGoPrev: p.canGoPrevMonth,
            canGoNext: p.canGoNextMonth,
            onPrevMonth: () => context.read<BookingProvider>().changeMonth(-1),
            onNextMonth: () => context.read<BookingProvider>().changeMonth(1),
            onSelect: (d) => context.read<BookingProvider>().selectDate(d),
          ),
          if (!p.loadingDates &&
              p.availableDates.isEmpty &&
              p.scheduleError == null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                p.canGoNextMonth
                    ? 'No free dates this month. Try the next month.'
                    : 'No free dates left in the next 3 weeks. Please check back soon.',
              ),
            ),
          const SizedBox(height: 16),
          if (date == null)
            const Text('Choose a date to see the available times.')
          else ...[
            Text(
              'Available slots. ${date.day} ${monthName(date.month)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (p.loadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (p.slots.isEmpty && p.scheduleError == null)
              const Text(
                'There are no free times left on this day. Please choose another date.',
              )
            else
              LayoutBuilder(
                builder: (context, c) {
                  final w = (c.maxWidth - 20) / 3;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final t in p.slots)
                        SizedBox(
                          width: w,
                          child: _SlotChip(
                            time: t,
                            selected: p.selectedTime == t,
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Back',
                  style: AppButtonStyle.outlined,
                  onPressed: () => context.read<BookingProvider>().back(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Next',
                  onPressed: p.canContinueFromSchedule
                      ? () =>
                            context.read<BookingProvider>().continueToConfirm()
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.time, required this.selected});

  final String time;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Time $time',
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.read<BookingProvider>().selectTime(time),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: selected ? AppColors.navy : Colors.white.withAlpha(110),
              border: Border.all(color: Colors.white.withAlpha(150)),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: selected ? Colors.white : AppColors.navy,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
