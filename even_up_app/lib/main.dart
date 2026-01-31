import 'package:flutter/cupertino.dart';
import 'package:even_up_app/features/auth/login_screen.dart';

void main() {
  runApp(const EvenUpApp());
}

class EvenUpApp extends StatelessWidget {
  const EvenUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: LoginScreen(),
    );
  }
}
