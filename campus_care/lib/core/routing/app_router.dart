import 'package:flutter/material.dart';

import '../../features/appointments/presentation/screens/booking/booking_flow_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/journal/presentation/screens/journal_detail_screen.dart';
import '../../features/journal/presentation/screens/journal_entry_screen.dart';
import '../../features/journal/presentation/screens/journal_list_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';
import '../../features/onboarding/models/onboarding_snapshot.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/consent_screen.dart';
import '../../features/profile/presentation/screens/edit_section_screen.dart';
import '../../features/profile/presentation/screens/intake_screen.dart';
import '../../features/profile/presentation/screens/personal_info_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/resources/presentation/screens/resource_category_screen.dart';
import '../../features/resources/presentation/screens/resource_detail_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import '../../features/sos/presentation/screens/sos_screen.dart';
import '../../features/wellness/presentation/screens/emotional_checkin_screen.dart';
import '../../features/wellness/presentation/screens/mood_checkin_screen.dart';
import '../../features/wellness/presentation/screens/streaks_screen.dart';

/// Every screen that is opened on top of another one, in one place.
///
/// Use it like this:
///   Navigator.of(context).push(AppRoutes.journal());
///   Navigator.of(context).pushReplacement(AppRoutes.login());
///   Navigator.of(context).pop();
///
/// Which "home" screen is shown (welcome, onboarding, the tabs...) is decided by
/// [AuthGate]; the four bottom-bar tabs are switched with [AppNav.toTab] (main_tabs.dart).
class AppRoutes {
  const AppRoutes._();

  static Route<T> _page<T>(Widget page) => MaterialPageRoute<T>(
    builder: (_) => Material(type: MaterialType.transparency, child: page),
  );

  // Auth
  static Route<void> login() => _page(const LoginScreen());
  static Route<void> register() => _page(const RegisterScreen());
  static Route<void> forgotPassword() => _page(const ForgotPasswordScreen());

  // Home tab
  static Route<void> moodCheckin() => _page(const MoodCheckinScreen());
  static Route<void> emotionalCheckin(String? moodEntryId) =>
      _page(EmotionalCheckinScreen(moodEntryId: moodEntryId));
  static Route<void> streaks() => _page(const StreaksScreen());
  static Route<void> sos() => _page(const SosScreen());
  static Route<void> resources() => _page(const ResourcesScreen());
  static Route<void> resourceCategory(int id) =>
      _page(ResourceCategoryScreen(categoryId: id));
  static Route<void> resourceItem(String id) =>
      _page(ResourceDetailScreen(resourceId: id));
  static Route<void> journal() => _page(const JournalListScreen());
  static Route<void> journalNew() => _page(const JournalEntryScreen());
  static Route<void> journalEntry(String id) =>
      _page(JournalDetailScreen(entryId: id));

  // Appointments tab
  static Route<void> book() => _page(const BookingFlowScreen());

  // Messages tab
  static Route<void> chat(String conversationId) =>
      _page(ChatScreen(conversationId: conversationId));

  // Profile tab
  static Route<void> profilePersonal() => _page(const PersonalInfoScreen());
  static Route<void> profileIntake() => _page(const IntakeScreen());
  static Route<void> profileConsent() => _page(const ConsentScreen());
  static Route<void> profileSettings() => _page(const SettingsScreen());
  static Route<void> profilePassword() => _page(const ChangePasswordScreen());
  static Route<void> profileEdit(OnboardingStep step) =>
      _page(EditSectionScreen(section: step.name));
}
