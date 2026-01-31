import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:even_up_app/core/config.dart';
import 'package:even_up_app/core/models/friend.dart';
import 'package:even_up_app/core/active_state.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _category = 'Other';
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

  Future<void> _saveGroup() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final members = ['local-user-123', ..._selectedMemberIds];
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/groups'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'members': members,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        activeGroupState.notifyGroupsChanged();
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to create group');
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
        middle: const Text('Create Group'),
        trailing: _isLoading 
          ? const CupertinoActivityIndicator()
          : CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Text('Done'),
              onPressed: _saveGroup,
            ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Group Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _nameController,
                  placeholder: 'Group Name',
                  prefix: const Icon(CupertinoIcons.group, size: 20),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Members'),
              children: _availableFriends.isEmpty 
                ? [const CupertinoListTile(title: Text('Loading friends...'))]
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
            CupertinoListSection.insetGrouped(
              header: const Text('Category'),
              children: [
                _buildCategoryTile('Trip', CupertinoIcons.airplane),
                _buildCategoryTile('Home', CupertinoIcons.house),
                _buildCategoryTile('Couple', CupertinoIcons.heart),
                _buildCategoryTile('Other', CupertinoIcons.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String title, IconData icon) {
    return CupertinoListTile(
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: _category == title 
        ? const Icon(CupertinoIcons.checkmark, color: CupertinoColors.activeBlue) 
        : null,
      onTap: () => setState(() => _category = title),
    );
  }
}
