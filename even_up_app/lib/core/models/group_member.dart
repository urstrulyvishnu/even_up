class GroupMember {
  final String id;
  final String name;
  final DateTime joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: _safeString(json['id']),
      name: _safeString(json['name'], defaultValue: 'UnknownMember'),
      joinedAt: json['joinedAt'] != null ? (DateTime.tryParse(json['joinedAt'].toString()) ?? DateTime.now()) : DateTime.now(),
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
