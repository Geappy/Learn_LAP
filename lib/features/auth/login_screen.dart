import 'package:flutter/material.dart';
import '../../data/auth_repo.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

import '../../design_system/widgets/app_scaffold.dart';
import '../../design_system/widgets/app_button.dart';
import '../../design_system/tokens/spacing.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _loading = false;
  String? _err;

  Future<void> _login() async {
    setState(() { _loading = true; _err = null; });
    try {
      final username = _u.text.trim();
      final password = _p.text;

      if (username.isEmpty) throw Exception('Username required.');
      if (password.isEmpty) throw Exception('Password required.');

      final auth = AuthRepo();
      final exists = await auth.hasAccount(username);
      if (!exists) {
        throw Exception('No account found. Please register first.');
      }

      await auth.signIn(username: username, password: password);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Login',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form fields
              TextField(
                controller: _u,
                decoration: const InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _p,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onEditingComplete: _loading ? null : _login,
              ),

              // Error message (styled)
              const SizedBox(height: AppSpacing.md),
              if (_err != null) ...[
                Text(_err!, style: TextStyle(color: scheme.error)),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Primary action
              AppButton(
                label: _loading ? 'Please wait…' : 'Login',
                icon: Icons.login,
                onPressed: _loading ? null : _login,
              ),

              // Secondary action
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
