/// Only plain web links may be opened from resource content (no tel:, intent:, javascript: ...).
Uri? safeWebUri(String? raw) {
  if (raw == null) return null;
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
  return (uri.scheme == 'https' || uri.scheme == 'http') ? uri : null;
}
