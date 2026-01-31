import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:even_up_app/core/models/group.dart';

class GroupInfoScreen extends StatelessWidget {
  final Group group;
  const GroupInfoScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMMM d, yyyy');
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Group Info'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildMetadataSection(formatter),
            const SizedBox(height: 32),
            _buildMembersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _getGroupIconColor(group.icon).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getGroupIcon(group.icon),
            size: 50,
            color: _getGroupIconColor(group.icon),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          group.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(DateFormat formatter) {
    return CupertinoListSection.insetGrouped(
      header: const Text('Details'),
      children: [
        CupertinoListTile(
          title: const Text('Created'),
          subtitle: Text(formatter.format(group.createdAt)),
          leading: const Icon(CupertinoIcons.calendar, color: CupertinoColors.systemGrey),
        ),
        CupertinoListTile(
          title: const Text('ID'),
          subtitle: Text(group.id),
          leading: const Icon(CupertinoIcons.tag, color: CupertinoColors.systemGrey),
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return CupertinoListSection.insetGrouped(
      header: Text('${group.members?.length ?? 0} Members'),
      children: group.members?.map((member) => CupertinoListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: CupertinoColors.systemGrey5,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        title: Text(member.name),
        subtitle: member.id == group.createdBy ? const Text('Group Creator') : null,
      )).toList() ?? [
        const CupertinoListTile(title: Text('No members found'))
      ],
    );
  }

  IconData _getGroupIcon(String? icon) {
    switch (icon) {
      case 'home':
        return CupertinoIcons.house_fill;
      case 'trip':
        return CupertinoIcons.airplane;
      case 'coffee':
        return CupertinoIcons.cart_fill;
      case 'group':
      default:
        return CupertinoIcons.person_3_fill;
    }
  }

  Color _getGroupIconColor(String? icon) {
    switch (icon) {
      case 'home':
        return CupertinoColors.systemGreen;
      case 'trip':
        return CupertinoColors.systemBlue;
      case 'coffee':
        return CupertinoColors.systemBrown;
      case 'group':
      default:
        return CupertinoColors.systemOrange;
    }
  }
}
