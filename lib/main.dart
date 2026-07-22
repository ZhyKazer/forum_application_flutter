import 'package:flutter/material.dart';
import 'package:forum_application_flutter/screens/login_screen.dart';
import 'package:forum_application_flutter/screens/registration_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:forum_application_flutter/screens/home_screen.dart';
import 'package:forum_application_flutter/utils/app_color.dart';

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
      home: HomeScreen(),
    );
  }
}
