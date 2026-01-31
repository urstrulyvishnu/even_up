import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:even_up_app/core/config.dart';

import 'package:even_up_app/features/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        throw Exception('Failed to log in');
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

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Account created! You can now sign in.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to create account');
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
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                CupertinoIcons.square_split_2x1_fill,
                size: 80,
                color: CupertinoColors.activeBlue,
              ),
              const SizedBox(height: 16),
              const Text(
                'EvenUp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 48),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _emailController,
                    placeholder: 'Email',
                    prefix: const Icon(CupertinoIcons.mail, size: 20),
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _passwordController,
                    placeholder: 'Password',
                    prefix: const Icon(CupertinoIcons.lock, size: 20),
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : CupertinoButton.filled(
                      onPressed: _handleLogin,
                      child: const Text('Sign In'),
                    ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _handleSignup,
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
