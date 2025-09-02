import 'package:flutter/material.dart';
import '../../data/run_repo.dart';
import '../../data/auth_repo.dart';
import '../../domain/user_deck_run.dart';
import '../decks/select_deck_screen.dart';
import '../../core/supabase_client.dart';
import '../auth/login_screen.dart';

// ⬇️ for card counts
import '../../data/card_repo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = RunRepo();
  final _cardRepo = CardRepo(); // for counts
  final Map<String, int> _cardCounts = {}; // deckId -> count

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
      _prefetchCardCounts(); // fetch counts after runs arrive
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _prefetchCardCounts() async {
    final ids = runs.map((r) => r.run.deckId).toSet();
    for (final deckId in ids) {
      if (_cardCounts.containsKey(deckId)) continue;
      try {
        final cards = await _cardRepo.listCards(deckId);
        if (!mounted) return;
        setState(() {
          _cardCounts[deckId] = cards.length;
        });
      } catch (_) {
        // ignore errors for count bubble; keep UI responsive
      }
    }
  }

  Future<void> _createRunFlow() async {
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
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: runs.length,
                  itemBuilder: (context, i) {
                    final r = runs[i];
                    final deckId = r.run.deckId;
                    final count = _cardCounts[deckId];
                    final scheme = Theme.of(context).colorScheme;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Open study for ${r.deckName} (${r.run.label})')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon links
                              Icon(Icons.menu_book_outlined, color: scheme.primary),

                              const SizedBox(width: 16),

                              // Textblock (nimmt so viel Platz wie nötig)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      r.run.label.isEmpty ? 'Untitled run' : r.run.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${r.deckName} • ${r.deckDescription}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Counter direkt rechts vom Textblock (mit Abstand)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, right: 8), // 👈 Abstand zur Delete-Icon
                                child: _CountPill(count: count),
                              ),

                              // Delete ganz rechts
                              IconButton(
                                tooltip: 'Delete run',
                                icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
                                onPressed: () async {
                                  await RunRepo().deleteRun(r.run.id);
                                  _load();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
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

/// pill-style count bubble that adapts to light/dark
class _CountPill extends StatelessWidget {
  final int? count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.secondaryContainer;
    final fg = scheme.onSecondaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant, width: 1),
      ),
      child: Text(
        count == null ? '…' : '$count',
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
