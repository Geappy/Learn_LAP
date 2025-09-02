import 'package:flutter/material.dart';
import '../data/deck_repo.dart';
import '../data/run_repo.dart';
import '../domain/deck.dart';

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
        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'e.g. Exam prep')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, c.text.trim().isEmpty ? 'default' : c.text.trim()), child: const Text('Create')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select deck')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: decks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = decks[i];
                return ListTile(
                  title: Text(d.name),
                  subtitle: Text(d.description),
                  onTap: () => _createRun(d),
                );
              },
            ),
    );
  }
}
