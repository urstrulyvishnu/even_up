import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:even_up_app/core/config.dart';
import 'package:even_up_app/core/models/friend.dart';
import 'package:even_up_app/core/models/group.dart';

class AddMemberScreen extends StatefulWidget {
  final Group group;
  const AddMemberScreen({super.key, required this.group});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  bool _isLoading = false;
  List<Friend> _availableFriends = [];
  final Set<String> _selectedMemberIds = {};

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  Future<void> _fetchFriends() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/friends'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availableFriends = data.map((f) => Friend.fromJson(f)).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching friends: $e');
    }
  }

  Future<void> _addMembers() async {
    if (_selectedMemberIds.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/groups/members'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'groupId': widget.group.id,
          'members': _selectedMemberIds.toList(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to add members');
      }
    } catch (e) {
      if (!mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Add to ${widget.group.name}'),
        trailing: _isLoading 
          ? const CupertinoActivityIndicator()
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Add'),
              onPressed: _selectedMemberIds.isEmpty ? null : _addMembers,
            ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Select Friends'),
              children: _availableFriends.isEmpty 
                ? [const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CupertinoActivityIndicator()))]
                : _availableFriends.map((friend) {
                    final isSelected = _selectedMemberIds.contains(friend.id);
                    return CupertinoListTile(
                      leading: const Icon(CupertinoIcons.person_crop_circle),
                      title: Text(friend.name),
                      trailing: isSelected 
                        ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                        : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedMemberIds.remove(friend.id);
                          } else {
                            _selectedMemberIds.add(friend.id);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
