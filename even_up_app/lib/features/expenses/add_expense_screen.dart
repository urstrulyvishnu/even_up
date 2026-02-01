import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:even_up_app/core/config.dart';
import 'package:even_up_app/core/models/group.dart';
import 'package:even_up_app/core/active_state.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? groupId;
  final CupertinoTabController? tabController;
  const AddExpenseScreen({super.key, this.groupId, this.tabController});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _splitType = 'Equally';
  bool _isLoading = false;
  
  List<Group> _availableGroups = [];
  String? _selectedGroupId;
  bool _isFetchingGroups = false;
  String _searchQuery = '';
  String _memberSearchQuery = '';
  Set<String> _selectedMemberIds = {};
  final Map<String, TextEditingController> _exactAmountControllers = {};

  @override
  void initState() {
    super.initState();
    _availableGroups = [];
    _selectedGroupId = widget.groupId ?? activeGroupState.currentGroupId;
    
    // Listen for changes in active group (e.g. when switching tabs)
    activeGroupState.addListener(_onActiveGroupChanged);
    
    // Always fetch groups to populate the list
    _fetchGroups();
  }

  @override
  void dispose() {
    activeGroupState.removeListener(_onActiveGroupChanged);
    _descriptionController.dispose();
    _amountController.dispose();
    for (var controller in _exactAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onActiveGroupChanged() {
    if (mounted) {
      // Re-fetch groups because the list might have changed (e.g. new group created)
      _fetchGroups();
      
      if (widget.groupId == null) {
        _updateSelection();
      }
    }
  }

  void _updateSelection() {
    final activeId = activeGroupState.currentGroupId;
    setState(() {
      if (activeId != null) {
        _selectedGroupId = activeId;
      } else if (_selectedGroupId == null && _availableGroups.isNotEmpty) {
        _selectedGroupId = _availableGroups.first.id;
      }
      _reorderGroups();
      _updateSelectedMembers();
    });
  }

  void _syncExactAmountControllers() {
    // Add missing controllers
    for (var id in _selectedMemberIds) {
      _exactAmountControllers.putIfAbsent(id, () => TextEditingController(text: '0.00'));
    }
    // Note: We don't necessarily remove them to avoid losing data if user deselects and reselects
  }

  void _updateSelectedMembers() {
    if (_selectedGroupId == null || _availableGroups.isEmpty) {
      _selectedMemberIds = {};
      return;
    }
    
    try {
      final group = _availableGroups.firstWhere(
        (g) => g.id == _selectedGroupId, 
        orElse: () => _availableGroups.first,
      );

      if (group.members != null) {
        _selectedMemberIds = group.members!.map((m) => m.id).toSet();
        _syncExactAmountControllers();
      } else {
        _selectedMemberIds = {};
      }
    } catch (e) {
      debugPrint('AddExpenseScreen: Error updating selected members: $e');
      _selectedMemberIds = {};
    }
  }

  void _reorderGroups() {
    if (_selectedGroupId == null || _availableGroups.isEmpty) return;
    
    final selectedIndex = _availableGroups.indexWhere((g) => g.id == _selectedGroupId);
    if (selectedIndex > 0) {
      final selectedGroup = _availableGroups.removeAt(selectedIndex);
      _availableGroups.insert(0, selectedGroup);
    }
  }

  Future<void> _fetchGroups() async {
    if (!mounted) return;
    setState(() => _isFetchingGroups = true);
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/groups'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availableGroups = data.map((json) => Group.fromJson(json)).toList();
          });
          _updateSelection();
        }
      }
    } catch (e) {
      debugPrint('Error fetching groups: $e');
    } finally {
      if (mounted) setState(() => _isFetchingGroups = false);
    }
  }

  Future<void> _saveExpense() async {
    if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final targetGroupId = _selectedGroupId ?? widget.groupId;
      if (targetGroupId == null) {
        throw Exception('Please select a group');
      }

      final List<Map<String, dynamic>> splitWithData = [];
      if (_splitType == 'Equally') {
        for (var id in _selectedMemberIds) {
          splitWithData.add({'userId': id});
        }
      } else {
        for (var id in _selectedMemberIds) {
          final amountStr = _exactAmountControllers[id]?.text ?? '0.00';
          splitWithData.add({
            'userId': id,
            'amount': double.tryParse(amountStr) ?? 0.0,
          });
        }
      }

      final expenseData = {
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'groupId': targetGroupId,
        'paidBy': 'local-user-123', // Updated to match local-server.js
        'splitType': _splitType,
        'splitWith': splitWithData,
      };

      debugPrint('AddExpenseScreen: Saving expense with data: $expenseData');

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/expenses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expenseData),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        
        if (widget.groupId != null) {
          // If we have a groupId, we were likely pushed from a detail screen
          Navigator.of(context).pop(true);
        } else {
          // If no groupId, we are likely in the "Add" tab. 
          // Reset form and switch to first tab after this build frame.
          _resetState();
          if (widget.tabController != null) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                widget.tabController!.index = 0; // Switch back to 'Groups'
              }
            });
          }
        }
      } else {
        throw Exception('Failed to save expense: ${response.statusCode}');
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

  void _resetState() {
    setState(() {
      _descriptionController.clear();
      _amountController.clear();
      _splitType = 'Equally';
      _selectedMemberIds = {};
      _exactAmountControllers.clear();
      _updateSelectedMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Expense'),
        trailing: _isLoading
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saveExpense,
                child: const Text('Save'),
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            if (widget.groupId == null)
              _availableGroups.isEmpty && _isFetchingGroups
                ? const SizedBox(height: 100, child: Center(child: CupertinoActivityIndicator()))
                : _buildGroupSelector(),
            _buildMemberSelector(),
            CupertinoListSection.insetGrouped(
              header: const Text('Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _descriptionController,
                  placeholder: 'Description',
                  prefix: const Icon(CupertinoIcons.pencil, size: 20),
                ),
                CupertinoTextFormFieldRow(
                  controller: _amountController,
                  placeholder: '0.00',
                  prefix: const Icon(CupertinoIcons.money_dollar, size: 20),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('Split Method'),
              children: [
                CupertinoListTile(
                  title: const Text('Split Equally'),
                  trailing: _splitType == 'Equally'
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                      : null,
                  onTap: () => setState(() => _splitType = 'Equally'),
                ),
                CupertinoListTile(
                  title: const Text('Exact Amounts'),
                  trailing: _splitType == 'Exact'
                      ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
                      : null,
                  onTap: () => setState(() => _splitType = 'Exact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
          child: Text(
            'SELECT GROUP',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CupertinoSearchTextField(
            placeholder: 'Search groups...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        SizedBox(
          height: 100, // Increased height for safety
          child: Builder(
            builder: (context) {
              final List<Group> allGroups = _availableGroups;
              final String query = ((_searchQuery as dynamic) is String ? _searchQuery : '').toLowerCase();
              
              final List<Group> filteredGroups = allGroups.where((g) {
                final dynamic rawName = g.name;
                if (rawName is String) {
                  return rawName.toLowerCase().contains(query);
                }
                return 'unnamed'.contains(query);
              }).toList();

              if (filteredGroups.isEmpty) {
                return const Center(
                  child: Text('No groups found', style: TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 13)),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
                  final isSelected = _selectedGroupId == group.id;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedGroupId = group.id;
                        _reorderGroups();
                        _updateSelectedMembers();
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? _getGroupIconColor(group.icon)
                                : _getGroupIconColor(group.icon).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: isSelected 
                                ? Border.all(color: _getGroupIconColor(group.icon), width: 3)
                                : null,
                            ),
                            child: Icon(
                              _getGroupIcon(group.icon),
                              color: isSelected ? CupertinoColors.white : _getGroupIconColor(group.icon),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            group.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? CupertinoColors.label : CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSelector() {
    final Group? currentGroup = _availableGroups.cast<Group?>().firstWhere(
      (g) => g?.id == _selectedGroupId, 
      orElse: () => _availableGroups.isNotEmpty ? _availableGroups.first : null
    );

    if (currentGroup == null) return const SizedBox.shrink();
    if (currentGroup.members == null || currentGroup.members!.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(child: Text('No members in group', style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel))),
      );
    }

    final String query = ((_memberSearchQuery as dynamic) is String ? _memberSearchQuery : '').toLowerCase();
    final filteredMembers = currentGroup.members!.where((m) {
      final dynamic rawMemberName = m.name;
      if (rawMemberName is String) {
        return rawMemberName.toLowerCase().contains(query);
      }
      return 'unknown'.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
          child: Text(
            'SPLIT WITH',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.secondaryLabel,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: CupertinoSearchTextField(
            placeholder: 'Search members...',
            onChanged: (value) => setState(() => _memberSearchQuery = value),
          ),
        ),
        SizedBox(
          height: _splitType == 'Exact' ? 140 : 100, // Increased for exact split fields
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: filteredMembers.length,
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              final isSelected = _selectedMemberIds.contains(member.id);
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedMemberIds.length > 1) {
                        _selectedMemberIds.remove(member.id);
                      }
                    } else {
                      _selectedMemberIds.add(member.id);
                      _syncExactAmountControllers();
                    }
                  });
                },
                child: Container(
                  width: 80, // Slightly wider to accommodate text field
                  margin: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: CupertinoColors.activeBlue, width: 2) : null,
                        ),
                        child: Center(
                          child: Text(
                            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: isSelected ? CupertinoColors.white : CupertinoColors.secondaryLabel,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        member.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? CupertinoColors.label : CupertinoColors.secondaryLabel,
                        ),
                      ),
                      if (_splitType == 'Exact' && isSelected) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 24,
                          child: CupertinoTextField(
                            controller: _exactAmountControllers[member.id],
                            placeholder: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            padding: EdgeInsets.zero,
                            style: const TextStyle(fontSize: 12),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getGroupIcon(String? icon) {
    final String iconName = (icon ?? '').toString();
    switch (iconName) {
      case 'home':
        return CupertinoIcons.house_fill;
      case 'trip':
        return CupertinoIcons.airplane;
      case 'coffee':
        return CupertinoIcons.cart_fill;
      default:
        return CupertinoIcons.person_3_fill;
    }
  }

  Color _getGroupIconColor(String? icon) {
    final String iconName = (icon ?? '').toString();
    switch (iconName) {
      case 'home':
        return CupertinoColors.systemGreen;
      case 'trip':
        return CupertinoColors.systemBlue;
      case 'coffee':
        return CupertinoColors.systemBrown;
      default:
        return CupertinoColors.systemOrange;
    }
  }
}
