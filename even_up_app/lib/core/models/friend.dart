class Friend {
  final String id;
  final String name;
  final String email;

  Friend({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: _safeString(json['id']),
      name: _safeString(json['name'], defaultValue: 'Unknown'),
      email: _safeString(json['email']),
    );
  }

  static String _safeString(dynamic value, {String defaultValue = ''}) {
    if (value is String) return value;
    if (value == null) return defaultValue;
    try {
      final String s = '$value';
      if (s == 'undefined' || s == 'null') return defaultValue;
      return s;
    } catch (_) {
      return defaultValue;
    }
  }
}
