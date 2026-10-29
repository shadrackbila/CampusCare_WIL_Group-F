import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/utils/date_format.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/error_banner.dart';
import '../../../../../shared/widgets/glass_card.dart';
import '../../../../../shared/widgets/info_row.dart';
import '../../viewModels/booking_provider.dart';
import '../../widgets/booking_stepper.dart';

class ConfirmStep extends StatelessWidget {
  const ConfirmStep({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final date = p.selectedDate;
    final time = p.selectedTime;
    final when = (date == null || time == null)
        ? ''
        : '${formatLongDate(date)}\n${formatTime12(int.parse(time.substring(0, 2)), int.parse(time.substring(3, 5)))}';

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BookingStepper(step: 2),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appointment Confirmation',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text('Please review your details before confirming.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InfoRow(
            icon: Icons.calendar_month,
            title: 'Date & Time',
            value: when,
            onTap: p.booking
                ? null
                : () => context.read<BookingProvider>().editDateTime(),
          ),
          InfoRow(
            icon: Icons.person,
            title: 'Practitioner',
            value:
                p.practitioner?.displayName ??
                "No preference (we'll assign one for you)",
            onTap: p.booking
                ? null
                : () => context.read<BookingProvider>().editPractitioner(),
          ),
          InfoRow(
            icon: Icons.groups,
            title: 'Type of Support',
            value: p.service?.name ?? 'Not available',
            onTap: (p.booking || p.services.length < 2)
                ? null
                : () => _pickService(context),
          ),
          const SizedBox(height: 8),
          if (p.confirmError != null) ...[
            ErrorBanner(p.confirmError!),
            const SizedBox(height: 12),
          ],
          AppButton(
            label: 'Edit date or Time',
            style: AppButtonStyle.outlined,
            onPressed: p.booking
                ? null
                : () => context.read<BookingProvider>().editDateTime(),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Confirm Appointment',
            loading: p.booking,
            onPressed: p.service == null
                ? null
                : () => context.read<BookingProvider>().confirm(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickService(BuildContext context) async {
    final booking = context.read<BookingProvider>();
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Type of Support',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            for (final s in booking.services)
              ListTile(
                title: Text(s.name),
                subtitle: s.description == null ? null : Text(s.description!),
                trailing: s.id == booking.service?.id
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(ctx).pop(s.id),
              ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    for (final s in booking.services) {
      if (s.id == picked) booking.setService(s);
    }
  }
}
