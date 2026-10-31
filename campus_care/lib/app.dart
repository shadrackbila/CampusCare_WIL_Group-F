import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/routing/auth_gate.dart';
import '../core/routing/main_tabs.dart';
import '../core/theme/app_theme.dart';
import '../features/appointments/data/appointment_repository.dart';
import '../features/appointments/presentation/viewModels/appointment_provider.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/session_preferences.dart';
import '../features/auth/presentation/viewModels/auth_provider.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/journal/presentation/viewModels/journal_provider.dart';
import '../features/messaging/data/messaging_repository.dart';
import '../features/messaging/presentation/viewModels/messaging_provider.dart';
import '../features/notifications/data/notification_repository.dart';
import '../features/notifications/presentation/viewModels/notification_provider.dart';
import '../features/onboarding/data/onboarding_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/data/settings_repository.dart';
import '../features/profile/presentation/viewModels/profile_provider.dart';
import '../features/profile/presentation/viewModels/settings_provider.dart';
import '../features/resources/data/resource_repository.dart';
import '../features/resources/presentation/viewModels/resources_provider.dart';
import '../features/sos/data/safety_repository.dart';
import '../features/wellness/data/wellness_repository.dart';
import '../features/wellness/presentation/viewModels/wellness_provider.dart';
import '../shared/platform/external_launcher.dart';

class CampusCareApp extends StatefulWidget {
  const CampusCareApp({super.key});

  @override
  State<CampusCareApp> createState() => _CampusCareAppState();
}

class _CampusCareAppState extends State<CampusCareApp> {
  late final AuthRepository _authRepo = AuthRepository(
    Supabase.instance.client,
  );
  late final OnboardingRepository _onboardingRepo = OnboardingRepository(
    Supabase.instance.client,
  );
  late final WellnessRepository _wellnessRepo = SupabaseWellnessRepository(
    Supabase.instance.client,
  );
  late final AppointmentRepository _appointmentRepo =
      SupabaseAppointmentRepository(Supabase.instance.client);
  late final JournalRepository _journalRepo = SupabaseJournalRepository(
    Supabase.instance.client,
  );
  late final MessagingRepository _messagingRepo = SupabaseMessagingRepository(
    Supabase.instance.client,
  );
  late final NotificationRepository _notificationRepo =
      SupabaseNotificationRepository(Supabase.instance.client);
  late final SafetyRepository _safetyRepo = SupabaseSafetyRepository(
    Supabase.instance.client,
  );
  late final ResourceRepository _resourceRepo = SupabaseResourceRepository(
    Supabase.instance.client,
  );
  late final SettingsRepository _settingsRepo = SupabaseSettingsRepository(
    Supabase.instance.client,
  );
  late final ProfileRepository _profileRepo = SupabaseProfileRepository(
    Supabase.instance.client,
    _onboardingRepo,
  );
  late final AuthProvider _auth = AuthProvider(_authRepo, SessionPreferences());
  final MainTabs _tabs = MainTabs();

  @override
  void dispose() {
    _tabs.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: _authRepo),
        Provider<OnboardingRepository>.value(value: _onboardingRepo),
        Provider<WellnessRepository>.value(value: _wellnessRepo),
        Provider<AppointmentRepository>.value(value: _appointmentRepo),
        Provider<MessagingRepository>.value(value: _messagingRepo),
        Provider<SafetyRepository>.value(value: _safetyRepo),
        Provider<ExternalLauncher>.value(value: const UrlLauncherExternal()),
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider<MainTabs>.value(value: _tabs),
        // Cleared automatically when the logged-in student changes or logs out.
        ChangeNotifierProxyProvider<AuthProvider, WellnessProvider>(
          create: (_) => WellnessProvider(_wellnessRepo),
          update: (_, auth, wellness) => wellness!..bind(auth.student?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppointmentProvider>(
          create: (_) => AppointmentProvider(_appointmentRepo),
          update: (_, auth, appts) => appts!..bind(auth.student?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, JournalProvider>(
          create: (_) => JournalProvider(_journalRepo),
          update: (_, auth, j) => j!..bind(auth.student?.id),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MessagingProvider>(
          create: (_) => MessagingProvider(_messagingRepo),
          update: (_, auth, m) => m!..bind(auth.student?.userId),
        ),
        // Same content for everyone, so not tied to the logged-in student.
        ChangeNotifierProvider<ResourcesProvider>(
          create: (_) => ResourcesProvider(_resourceRepo),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (_) => SettingsProvider(_settingsRepo),
          update: (_, auth, s) => s!..bind(auth.student?.userId),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(_profileRepo),
          update: (_, auth, p) => p!..bind(auth.student?.id),
        ),
        // Live: opens a realtime subscription while logged in, closed on logout/dispose.
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(_notificationRepo),
          update: (_, auth, n) => n!..bind(auth.student?.userId),
        ),
      ],
      child: MaterialApp(
        title: 'CampusCare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}
