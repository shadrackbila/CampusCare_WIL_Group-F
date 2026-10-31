class UserSettings {
  const UserSettings({
    this.notificationsEnabled = true,
    this.appointmentReminders = true,
    this.streakNotifications = true,
    this.wellnessTips = true,
  });

  final bool notificationsEnabled;
  final bool appointmentReminders;
  final bool streakNotifications;
  final bool wellnessTips;

  UserSettings copyWith({
    bool? notificationsEnabled,
    bool? appointmentReminders,
    bool? streakNotifications,
    bool? wellnessTips,
  }) =>
      UserSettings(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        appointmentReminders: appointmentReminders ?? this.appointmentReminders,
        streakNotifications: streakNotifications ?? this.streakNotifications,
        wellnessTips: wellnessTips ?? this.wellnessTips,
      );

  static const selectColumns =
      'notifications_enabled, appointment_reminders, streak_notifications, wellness_tips';

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        notificationsEnabled: (j['notifications_enabled'] as bool?) ?? true,
        appointmentReminders: (j['appointment_reminders'] as bool?) ?? true,
        streakNotifications: (j['streak_notifications'] as bool?) ?? true,
        wellnessTips: (j['wellness_tips'] as bool?) ?? true,
      );

  Map<String, dynamic> toJson() => {
        'notifications_enabled': notificationsEnabled,
        'appointment_reminders': appointmentReminders,
        'streak_notifications': streakNotifications,
        'wellness_tips': wellnessTips,
      };

  @override
  bool operator ==(Object other) =>
      other is UserSettings &&
      other.notificationsEnabled == notificationsEnabled &&
      other.appointmentReminders == appointmentReminders &&
      other.streakNotifications == streakNotifications &&
      other.wellnessTips == wellnessTips;

  @override
  int get hashCode =>
      Object.hash(notificationsEnabled, appointmentReminders, streakNotifications, wellnessTips);
}
