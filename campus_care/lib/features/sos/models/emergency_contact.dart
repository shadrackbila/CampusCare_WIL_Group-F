enum SosKind { emergency, wellnessCentre, peerChat, other }

class EmergencyContact {
  const EmergencyContact({
    required this.id,
    required this.label,
    required this.contactType,
    this.description,
    this.phone,
    this.sortOrder = 0,
  });

  final String id;
  final String label;
  final String? description;
  final String? phone;

  /// 'phone' or 'in_app_chat'
  final String contactType;
  final int sortOrder;

  bool get isPhone => contactType == 'phone';

  /// Which of the three SOS actions this row is. The matching is by type and by the wording
  /// of the label, so the Wellness Centre can change the number or description freely.
  SosKind get kind {
    if (contactType == 'in_app_chat') return SosKind.peerChat;
    final l = label.toLowerCase();
    if (l.contains('emergency')) return SosKind.emergency;
    if (l.contains('wellness')) return SosKind.wellnessCentre;
    return SosKind.other;
  }

  static const selectColumns = 'id, label, description, phone, contact_type, sort_order';

  factory EmergencyContact.fromJson(Map<String, dynamic> j) => EmergencyContact(
        id: j['id'] as String,
        label: (j['label'] as String?) ?? '',
        description: j['description'] as String?,
        phone: j['phone'] as String?,
        contactType: (j['contact_type'] as String?) ?? 'phone',
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      );
}
