import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/widgets/page_header.dart';
import '../../../../../shared/widgets/sky_background.dart';
import '../../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../data/appointment_repository.dart';
import '../../viewModels/appointment_provider.dart';
import '../../viewModels/booking_provider.dart';
import 'booked_step.dart';
import 'confirm_step.dart';
import 'schedule_step.dart';
import 'select_practitioner_step.dart';

/// The 3-step booking flow: practitioner, date and time, confirm (then "booked").
/// One [BookingProvider] lives for as long as this screen is open.
class BookingFlowScreen extends StatelessWidget {
  const BookingFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppointmentRepository>();
    final appointments = context.read<AppointmentProvider>();
    return ChangeNotifierProvider<BookingProvider>(
      create: (_) =>
          BookingProvider(repo, onBooked: () => appointments.load(silent: true))
            ..loadSetup(),
      child: const _FlowBody(),
    );
  }
}

class _FlowBody extends StatelessWidget {
  const _FlowBody();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final atEdge =
        p.step == BookingStep.practitioner || p.step == BookingStep.booked;

    void leave() => Navigator.of(context).maybePop();

    final Widget body;
    switch (p.step) {
      case BookingStep.practitioner:
        body = const SelectPractitionerStep();
      case BookingStep.schedule:
        body = const ScheduleStep();
      case BookingStep.confirm:
        body = const ConfirmStep();
      case BookingStep.booked:
        body = const BookedStep();
    }

    return PopScope(
      // The system back button steps back inside the flow before leaving it.
      canPop: atEdge,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<BookingProvider>().back();
      },
      child: SkyBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              PageHeader(actions: const [NotificationBell()],
                showBack: p.step != BookingStep.booked,
                onBack: () {
                  if (!context.read<BookingProvider>().back()) leave();
                },
              ),
              const SizedBox(height: 16),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
