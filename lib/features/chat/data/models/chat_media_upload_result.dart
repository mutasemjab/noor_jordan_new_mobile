class ChatMediaUploadResult {
  final int id;
  final String url;
  final String type;
  final int? durationSeconds;

  const ChatMediaUploadResult({
    required this.id,
    required this.url,
    required this.type,
    this.durationSeconds,
  });

  factory ChatMediaUploadResult.fromJson(Map<String, dynamic> json) {
    return ChatMediaUploadResult(
      id: _toInt(json['id']) ?? 0,
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'image',
      durationSeconds: _toInt(json['duration_seconds']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
