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
      id: json['id'],
      name: json['name'],
      joinedAt: DateTime.parse(json['joinedAt']),
    );
  }
}
