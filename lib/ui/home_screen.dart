import 'package:flutter/material.dart';
import '../data/run_repo.dart';
import '../data/auth_repo.dart';
import '../domain/user_deck_run.dart';
import 'select_deck_screen.dart';
import '../core/supabase_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = RunRepo();
  List<RunWithDeck> runs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await _repo.listMyRuns();
      setState(() => runs = data);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createRunFlow() async {
    // Go to deck selector, let user pick one; returns true if a run was created
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SelectDeckScreen()),
    );
    if (created == true) {
      _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Run created')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AppSupabase.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your decks'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(user.id.substring(0, 6))), // tiny visual of who’s logged in
            ),
          IconButton(
            onPressed: () async {
              await AuthRepo().signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const _LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : runs.isEmpty
              ? const Center(child: Text('No runs yet. Tap + to start.'))
              : ListView.separated(
                  itemCount: runs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = runs[i];
                    return ListTile(
                      title: Text(r.deckName),
                      subtitle: Text('${r.run.label} • ${r.deckDescription}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await RunRepo().deleteRun(r.run.id);
                          _load();
                        },
                      ),
                      onTap: () {
                        // later: navigate to StudyScreen(runId: r.run.id)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Open study for ${r.deckName} (${r.run.label})')),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createRunFlow,
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

/// Tiny inline login screen so main.dart stays clean in this example.
/// If you already have a separate LoginScreen, keep using it.
class _LoginScreen extends StatefulWidget {
  const _LoginScreen();
  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<_LoginScreen> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  bool _loading = false;
  String? _err;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Login / Sign up', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              TextField(controller: _u, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 8),
              TextField(controller: _p, decoration: const InputDecoration(labelText: 'Password (min 6)'), obscureText: true),
              const SizedBox(height: 12),
              if (_err != null) Text(_err!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : () async {
                  setState(() { _loading = true; _err = null; });
                  try {
                    final auth = AuthRepo();
                    try {
                      await auth.signIn(username: _u.text, password: _p.text);
                    } catch (_) {
                      await auth.signUp(username: _u.text, password: _p.text);
                    }
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } catch (e) {
                    setState(() { _err = e.toString(); });
                  } finally {
                    setState(() { _loading = false; });
                  }
                },
                child: Text(_loading ? '...' : 'Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
