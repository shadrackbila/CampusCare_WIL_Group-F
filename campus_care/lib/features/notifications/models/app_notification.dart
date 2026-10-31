class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  bool get isAppointmentRelated => type.startsWith('appointment_') || type == 'new_appointment';
  bool get isAlert => type == 'appointment_cancelled';

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  static const selectColumns = 'id, type, title, body, read, created_at';

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        type: (j['type'] as String?) ?? 'general',
        title: (j['title'] as String?) ?? '',
        body: (j['body'] as String?) ?? '',
        read: (j['read'] as bool?) ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
