import 'package:flutter/cupertino.dart';
import 'package:even_up_app/features/dashboard/dashboard_screen.dart';
import 'package:even_up_app/features/friends/friends_screen.dart';
import 'package:even_up_app/features/activity/activity_screen.dart';
import 'package:even_up_app/features/account/account_screen.dart';
import 'package:even_up_app/features/expenses/add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CupertinoTabController _tabController = CupertinoTabController();
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'Navigator Groups'),
    GlobalKey<NavigatorState>(debugLabel: 'Navigator Friends'),
    GlobalKey<NavigatorState>(debugLabel: 'Navigator Add'),
    GlobalKey<NavigatorState>(debugLabel: 'Navigator Activity'),
    GlobalKey<NavigatorState>(debugLabel: 'Navigator Account'),
  ];
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const FriendsScreen(),
      AddExpenseScreen(tabController: _tabController),
      const ActivityScreen(),
      const AccountScreen(),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_tabController.index == index) {
      // Tapping the already selected tab: Pop to root
      _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_2),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid, size: 32),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bolt_fill),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle),
            label: 'Account',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          key: ValueKey('TabView_$index'),
          navigatorKey: _navigatorKeys[index],
          builder: (context) => _screens[index],
        );
      },
    );
  }
}
