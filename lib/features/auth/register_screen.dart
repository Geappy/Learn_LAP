import 'package:flutter/material.dart';
import '../../data/auth_repo.dart';
import '../home/home_screen.dart';

import '../../design_system/widgets/app_scaffold.dart';
import '../../design_system/widgets/app_button.dart';
import '../../design_system/tokens/spacing.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _loading = false;
  String? _err;
  String _availability = ''; // '', 'available', 'taken'

  Future<void> _checkAvailability() async {
    final name = _u.text.trim();
    if (name.isEmpty) return;
    final ok = await AuthRepo().isUsernameAvailable(name);
    setState(() => _availability = ok ? 'available' : 'taken');
  }

  Future<void> _register() async {
    setState(() { _loading = true; _err = null; });
    try {
      final username = _u.text.trim();
      final password = _p.text;
      if (username.isEmpty) throw Exception('Username required.');
      if (password.length < 6) throw Exception('Password must be at least 6 characters.');

      // quick re-check to avoid race with someone else registering at same time
      final ok = await AuthRepo().isUsernameAvailable(username);
      if (!ok) throw Exception('Username is already taken.');

      await AuthRepo().signUp(username: username, password: password);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
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

    Widget availText;
    switch (_availability) {
      case 'available':
        availText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
            const SizedBox(width: 6),
            Text('Username is available', style: TextStyle(color: Colors.green.shade700)),
          ],
        );
        break;
      case 'taken':
        availText = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 18, color: scheme.error),
            const SizedBox(width: 6),
            Text('Username is taken', style: TextStyle(color: scheme.error)),
          ],
        );
        break;
      default:
        availText = const SizedBox.shrink();
    }

    return AppScaffold(
      title: 'Create account',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _u,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (_) => setState(() => _availability = ''),
                onEditingComplete: _checkAvailability,
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(alignment: Alignment.centerLeft, child: availText),

              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _p,
                decoration: const InputDecoration(labelText: 'Password (min 6)'),
                obscureText: true,
              ),

              const SizedBox(height: AppSpacing.md),
              if (_err != null) ...[
                Text(_err!, style: TextStyle(color: scheme.error)),
                const SizedBox(height: AppSpacing.sm),
              ],

              AppButton(
                label: _loading ? 'Please wait…' : 'Create account',
                icon: Icons.person_add_alt_1,
                onPressed: _loading ? null : _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
