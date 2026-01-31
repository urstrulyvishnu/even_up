import 'package:flutter/cupertino.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Friends'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.person_add),
          onPressed: () {
            // TODO: Add friend
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Your Friends'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_crop_circle_fill, color: CupertinoColors.systemGrey),
                  title: const Text('John Doe'),
                  subtitle: const Text('You are all settled up'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {},
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_crop_circle_fill, color: CupertinoColors.systemGrey),
                  title: const Text('Jane Smith'),
                  subtitle: const Text('Jane owes you \$20.00'),
                  trailing: const CupertinoListTileChevron(),
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
