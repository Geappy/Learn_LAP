import 'core/secrets.dart';
import 'core/supabase_client.dart';
import 'features/home/home_screen.dart';
import 'features/auth/login_screen.dart';

import 'package:flutter/material.dart';
import 'design_system/theme/app_theme.dart';

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
      title: 'Your App',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: isAuthed ? const HomeScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
