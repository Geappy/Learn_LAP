import 'package:flutter/material.dart';
import '../data/auth_repo.dart';
import 'home_screen.dart';

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
    final availText = _availability == 'available'
        ? const Text('Username is available', style: TextStyle(color: Colors.green))
        : _availability == 'taken'
            ? const Text('Username is taken', style: TextStyle(color: Colors.red))
            : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _u,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (_) => setState(() => _availability = ''),
                onEditingComplete: _checkAvailability,
              ),
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerLeft, child: availText),
              const SizedBox(height: 8),
              TextField(
                controller: _p,
                decoration: const InputDecoration(labelText: 'Password (min 6)'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: Text(_loading ? '...' : 'Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
