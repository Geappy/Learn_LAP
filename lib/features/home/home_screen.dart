import 'package:flutter/material.dart';
import '../../data/run_repo.dart';
import '../../data/auth_repo.dart';
import '../../domain/user_deck_run.dart';
import '../decks/select_deck_screen.dart';
import '../../core/supabase_client.dart';
import '../auth/login_screen.dart';

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
              child: Center(child: Text(user.id.substring(0, 6))),
            ),
          IconButton(
            onPressed: () async {
              await AuthRepo().signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
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
