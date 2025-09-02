import 'core/secrets.dart';
import 'core/supabase_client.dart';
import 'package:flutter/material.dart';
import 'ui/home_screen.dart';
import 'ui/login_screen.dart';

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
      title: 'Flashcards',
      theme: ThemeData(useMaterial3: true),
      home: isAuthed ? const HomeScreen() : const LoginScreen(),
    );
  }
}
