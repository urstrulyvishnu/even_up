import 'package:even_up_app/core/models/group_member.dart';

class Group {
  final String id;
  final String name;
  final String createdBy;
  final DateTime createdAt;
  final List<GroupMember>? members;
  final String? icon;

  Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.members,
    this.icon,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unnamed Group',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      members: json['members'] != null
          ? (json['members'] as List).map((m) => GroupMember.fromJson(m)).toList()
          : null,
      icon: json['icon'],
    );
  }
}
