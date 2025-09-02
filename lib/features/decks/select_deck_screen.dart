import 'package:flutter/material.dart';
import '../../data/deck_repo.dart';
import '../../data/run_repo.dart';
import '../../domain/deck.dart';

import '../../design_system/widgets/app_scaffold.dart';
import '../../design_system/widgets/app_card.dart';
import '../../design_system/widgets/app_button.dart';
import '../../design_system/tokens/spacing.dart';

class SelectDeckScreen extends StatefulWidget {
  const SelectDeckScreen({super.key});
  @override
  State<SelectDeckScreen> createState() => _SelectDeckScreenState();
}

class _SelectDeckScreenState extends State<SelectDeckScreen> {
  final _deckRepo = DeckRepo();
  final _runRepo = RunRepo();
  List<Deck> decks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          // Keep logic identical; use AppButton for consistent look
          AppButton(
            label: 'Create',
            onPressed: () =>
                Navigator.pop(context, c.text.trim().isEmpty ? 'default' : c.text.trim()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select deck',
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : decks.isEmpty
              ? const _EmptyDecks()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 96),
                    itemCount: decks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final d = decks[i];
                      return AppCard(
                        header: Text(
                          d.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        child: Text(
                          d.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        footer: Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Use this deck',
                                icon: Icons.check_circle_outline,
                                onPressed: () => _createRun(d),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _createRun(d),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyDecks extends StatelessWidget {
  const _EmptyDecks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text('No decks available', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Please create or import a deck first.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
