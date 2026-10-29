import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/info_row.dart';
import '../../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.nowSa,
    this.busy = false,
    this.onCancel,
    this.onConfirm,
    this.onRebook,
  });

  final Appointment appointment;
  final DateTime nowSa;
  final bool busy;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onRebook;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final upcoming = a.tab(nowSa) == AppointmentTab.upcoming;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: upcoming ? _expanded(context) : _compact(context),
      ),
    );
  }

  Widget _expanded(BuildContext context) {
    final a = appointment;
    final moved = a.rescheduledFrom;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (a.needsConfirmation) ...[
          Text(
            moved == null
                ? 'Your appointment has been cancelled and rescheduled due to the practitioner’s unexpected unavailability.'
                : 'Your appointment for ${moved.day} ${monthName(moved.month).substring(0, 3)} ${moved.year} at '
                      '${formatTime12(moved.hour, moved.minute)} has been cancelled and rescheduled due to the '
                      'practitioner’s unexpected unavailability on that day or time.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Text(
            'New appointment details',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
        ],
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
        if (a.needsConfirmation) ...[
          const SizedBox(height: 4),
          AppButton(
            label: 'Confirm Appointment',
            loading: busy,
            onPressed: onConfirm,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: Text('Or')),
          ),
          AppButton(
            label: 'Rebook Appointment',
            style: AppButtonStyle.outlined,
            onPressed: busy ? null : onRebook,
          ),
        ] else if (a.canCancel(nowSa))
          AppButton(
            label: 'Cancel Appointment',
            style: AppButtonStyle.outlined,
            loading: busy,
            onPressed: onCancel,
          ),
      ],
    );
  }

  Widget _compact(BuildContext context) {
    final a = appointment;
    final reason = a.cancellationReason?.trim();
    return Semantics(
      label:
          '${formatLongDate(a.date)} ${a.date.year}, ${a.timeLabel}, '
          '${a.practitionerName ?? 'practitioner to be assigned'}, ${a.serviceName}, ${a.statusLabel(nowSa)}',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    '${a.date.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    monthName(a.date.month).substring(0, 3),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${a.date.year}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.practitionerName ?? 'Practitioner to be assigned',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(a.timeLabel),
                  Text(a.serviceName),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(reason, style: const TextStyle(fontSize: 13)),
                  ],
                  const SizedBox(height: 8),
                  _StatusChip(
                    label: a.statusLabel(nowSa),
                    status: a.status,
                    cancelledBy: a.cancelledBy,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.status,
    required this.cancelledBy,
  });

  final String label;
  final AppointmentStatus status;
  final String? cancelledBy;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case AppointmentStatus.confirmed:
      case AppointmentStatus.completed:
        bg = const Color(0xFFBFE3C9);
        fg = const Color(0xFF14532D);
      case AppointmentStatus.cancelled:
      case AppointmentStatus.noShow:
        bg = const Color(0xFFF2C9CF);
        fg = const Color(0xFF7A1020);
      case AppointmentStatus.pendingConfirmation:
      case AppointmentStatus.pending:
        bg = const Color(0xFFFFE7A8);
        fg = const Color(0xFF6B4A00);
      default:
        bg = Colors.white.withAlpha(150);
        fg = AppColors.navy;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
