import 'package:flutter/cupertino.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Account'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  Icon(CupertinoIcons.person_crop_circle_fill, size: 80, color: CupertinoColors.systemGrey),
                  SizedBox(height: 8),
                  Text('Showrya Dindi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('test@example.com', style: TextStyle(color: CupertinoColors.secondaryLabel)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_fill),
                  title: const Text('Profile Settings'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {},
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.bell_fill),
                  title: const Text('Notifications'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {},
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: const Text('Sign Out', style: TextStyle(color: CupertinoColors.destructiveRed)),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
