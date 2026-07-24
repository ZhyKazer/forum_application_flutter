import 'package:flutter/material.dart';
import 'package:forum_application_flutter/screens/home_screen.dart';
import 'package:forum_application_flutter/screens/login_screen.dart';
import 'package:forum_application_flutter/utils/app_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: AppColor.lightColorScheme,
        scaffoldBackgroundColor: AppColor.lightBackground,
      ),
      darkTheme: ThemeData(
        colorScheme: AppColor.darkColorScheme,
        scaffoldBackgroundColor: AppColor.darkBackground,
      ),
      themeMode: ThemeMode.dark,
      // home: ProfileScreen(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const LoginScreen() : const HomeScreen();
      },
    );
  }
}
