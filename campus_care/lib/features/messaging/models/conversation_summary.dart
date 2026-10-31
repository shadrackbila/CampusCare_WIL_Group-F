class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.kind,
    required this.otherName,
    required this.otherRole,
    this.photoUrl,
    this.lastBody,
    this.lastAt,
    this.unread = false,
  });

  final String id;
  final String kind;
  final String otherName;
  final String otherRole;
  final String? photoUrl;
  final String? lastBody;
  final DateTime? lastAt;
  final bool unread;
}
