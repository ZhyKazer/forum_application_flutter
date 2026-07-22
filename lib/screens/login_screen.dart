import 'package:flutter/material.dart';
import 'package:forum_application_flutter/screens/home_screen.dart';
import 'package:forum_application_flutter/screens/registration_screen.dart';
import 'package:forum_application_flutter/services/authentication_services.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authenticationService.login(email: email, password: password);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Material(
              shape: BeveledRectangleBorder(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(60),
                ),
                side: BorderSide(color: colors.outline),
              ),
              color: colors.surface,
              child: SizedBox(
                width: 600,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        cursorColor: colors.primary,
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                        ),
                        decoration: _inputDecoration(
                          colors: colors,
                          hintText: 'you@example.com',
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Password',
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) {
                          if (!_isLoading) _login();
                        },
                        cursorColor: colors.primary,
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                        ),
                        decoration: _inputDecoration(
                          colors: colors,
                          hintText: '**************',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 48,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'LOGIN',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don't have an Account?",
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w200,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required ColorScheme colors,
    required String hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.jetBrainsMono(color: colors.onSurfaceVariant),
      filled: true,
      fillColor: colors.surfaceContainer,
      prefixIcon: Icon(Icons.chevron_right, color: colors.primary),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );
  }
}

