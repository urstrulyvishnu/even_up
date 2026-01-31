import 'package:flutter/cupertino.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Activity'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Recent Activity'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.plus_circle_fill, color: CupertinoColors.activeBlue),
                  title: const Text('John added "Coffee"'),
                  subtitle: const Text('Yesterday'),
                  onTap: () {},
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.systemGreen),
                  title: const Text('You settled with Jane'),
                  subtitle: const Text('2 days ago'),
                  onTap: () {},
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_add_solid, color: CupertinoColors.systemOrange),
                  title: const Text('Jane added you to "Trip to Paris"'),
                  subtitle: const Text('3 days ago'),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
