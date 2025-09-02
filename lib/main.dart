import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'data/auth_repo.dart';
import 'data/deck_repo.dart';
import 'data/card_repo.dart';
import 'data/card_user_state_repo.dart';
import 'core/secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final isAuthed = AppSupabase.client.auth.currentUser != null;
    return MaterialApp(
      home: isAuthed ? const DecksDebugScreen() : const LoginScreen(),
    );
  }
}

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
                    // try sign in; if fails, sign up
                    try {
                      await auth.signIn(username: _u.text, password: _p.text);
                    } catch (_) {
                      await auth.signUp(username: _u.text, password: _p.text);
                    }
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const DecksDebugScreen()),
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

class DecksDebugScreen extends StatefulWidget {
  const DecksDebugScreen({super.key});
  @override
  State<DecksDebugScreen> createState() => _DecksDebugScreenState();
}

class _DecksDebugScreenState extends State<DecksDebugScreen> {
  final _deckRepo = DeckRepo();
  final _cardRepo = CardRepo();
  final _stateRepo = CardUserStateRepo();

  List decks = [];
  String? msg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _deckRepo.listAllDecks();
    setState(() => decks = d);
  }

  Future<void> _startRunAndTest(String deckId) async {
    setState(() => msg = 'Creating run...');
    // create a run
    final uid = AppSupabase.client.auth.currentUser!.id;
    final run = await AppSupabase.client.from('user_deck_runs').insert({
      'user_id': uid,
      'deck_id': deckId,
      'label': 'default',
    }).select('id').single();
    final runId = run['id'] as String;

    // fetch first card in deck
    final cards = await _cardRepo.listCards(deckId);
    if (cards.isEmpty) {
      setState(() => msg = 'No cards in this deck.');
      return;
    }
    final first = cards.first;

    // test writes: like + add note + mark right
    await _stateRepo.setLiked(runId: runId, cardId: first.id, liked: true);
    // runId-aware upserts:
    await AppSupabase.client.from('card_user_state').upsert({
      'user_id': uid,
      'run_id': runId,
      'card_id': first.id,
      'liked': true,
      'note': 'hello from debug screen',
      'times_right': 1,
      'status': 'learning',
      'last_reviewed': DateTime.now().toIso8601String(),
    });

    setState(() => msg = 'Run created, wrote state for first card ✅');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks (debug)'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthRepo().signOut();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        children: [
          if (msg != null) Padding(padding: const EdgeInsets.all(8), child: Text(msg!)),
          for (final d in decks)
            ListTile(
              title: Text(d.name),
              subtitle: Text(d.id),
              trailing: TextButton(
                onPressed: () => _startRunAndTest(d.id),
                child: const Text('Start run & test'),
              ),
            ),
        ],
      ),
    );
  }
}