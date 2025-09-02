import 'package:flutter/material.dart';
import '../../data/deck_repo.dart';
import '../../data/run_repo.dart';
import '../../domain/deck.dart';

import '../../design_system/widgets/app_scaffold.dart';
import '../../design_system/tokens/spacing.dart';

class SelectDeckScreen extends StatefulWidget {
  const SelectDeckScreen({super.key});
  @override
  State<SelectDeckScreen> createState() => _SelectDeckScreenState();
}

class _SelectDeckScreenState extends State<SelectDeckScreen> {
  final _deckRepo = DeckRepo();
  final _runRepo = RunRepo();

  final _search = TextEditingController();
  String _query = '';

  List<Deck> decks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      decks = await _deckRepo.listAllDecks();
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createRun(Deck deck) async {
    final label = await _askLabel(context);
    if (label == null) return;
    await _runRepo.createRun(deckId: deck.id, label: label);
    if (!mounted) return;
    Navigator.of(context).pop(true); // tell caller a run was created
  }

  Future<String?> _askLabel(BuildContext context) async {
    final c = TextEditingController(text: 'default');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Run label'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(
            hintText: 'e.g. Exam prep',
            labelText: 'Label',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              c.text.trim().isEmpty ? 'default' : c.text.trim(),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  List<Deck> get _filtered {
    if (_query.isEmpty) return decks;
    final q = _query.toLowerCase();
    return decks.where((d) {
      final name = d.name.toLowerCase();
      final desc = d.description.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select deck',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search decks…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            onPressed: () {
                              _search.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // List
                Expanded(
                  child: _filtered.isEmpty
                      ? const _EmptyFiltered()
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final d = _filtered[i];
                              // Condensed row style
                              return Card(
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  title: Text(
                                    d.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    d.description,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Use this deck',
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    onPressed: () => _createRun(d),
                                  ),
                                  onTap: () => _createRun(d),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _EmptyFiltered extends StatelessWidget {
  const _EmptyFiltered();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No decks match your search.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
