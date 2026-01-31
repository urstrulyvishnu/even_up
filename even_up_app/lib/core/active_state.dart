import 'package:flutter/foundation.dart';

class ActiveGroupState extends ChangeNotifier {
  static final ActiveGroupState _instance = ActiveGroupState._internal();
  factory ActiveGroupState() => _instance;
  ActiveGroupState._internal();

  String? _currentGroupId;

  String? get currentGroupId => _currentGroupId;

  void setActiveGroup(String? groupId) {
    if (_currentGroupId != groupId) {
      final oldId = _currentGroupId;
      _currentGroupId = groupId;
      debugPrint('ActiveGroupState: Changed from $oldId to $groupId');
      Future.microtask(() => notifyListeners());
    }
  }

  void clearActiveGroup() {
    if (_currentGroupId != null) {
      debugPrint('ActiveGroupState: Cleared active group: $_currentGroupId');
      _currentGroupId = null;
      Future.microtask(() => notifyListeners());
    }
  }

  void notifyGroupsChanged() {
    debugPrint('ActiveGroupState: Groups changed, notifying listeners');
    notifyListeners();
  }
}

final activeGroupState = ActiveGroupState();
