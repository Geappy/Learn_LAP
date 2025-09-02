import 'package:flutter/material.dart';
import 'core/supabase_client.dart';
import 'core/secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
  );
  runApp(const PlaceholderApp());
}

class PlaceholderApp extends StatelessWidget {
  const PlaceholderApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(body: Center(child: Text('Data layer ready'))),
  );
}
