import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/routing/main_tabs.dart';
import '../../../../../core/utils/date_format.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/info_row.dart';
import '../../viewModels/booking_provider.dart';
import '../../widgets/booking_stepper.dart';

class BookedStep extends StatelessWidget {
  const BookedStep({super.key});

  @override
  Widget build(BuildContext context) {
    final a = context.watch<BookingProvider>().booked;
    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BookingStepper(step: 3),
          const SizedBox(height: 24),
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFA9CDBF),
              child: Icon(
                Icons.event_available,
                size: 48,
                color: Color(0xFF0B4D2B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Appointment Booked',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 20),
          if (a != null) ...[
            InfoRow(
              icon: Icons.calendar_month,
              title: 'Date & Time',
              value: '${formatLongDate(a.date)}\n${a.timeLabel}',
            ),
            InfoRow(
              icon: Icons.person,
              title: 'Practitioner',
              value: a.practitionerName ?? 'To be assigned',
            ),
            InfoRow(
              icon: Icons.groups,
              title: 'Type of Support',
              value: a.serviceName,
            ),
          ],
          const SizedBox(height: 12),
          AppButton(
            label: 'View my appointments',
            onPressed: () => AppNav.toTab(context, AppTab.appointments),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Back to Home',
            style: AppButtonStyle.outlined,
            onPressed: () => AppNav.toTab(context, AppTab.home),
          ),
        ],
      ),
    );
  }
}
