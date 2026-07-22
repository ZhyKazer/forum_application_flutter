import 'package:flutter/material.dart';
import 'package:forum_application_flutter/services/authentication_services.dart';
import 'package:forum_application_flutter/utils/grid_background.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authenticationService.register(
        email: email,
        password: password,
        username: username.isEmpty ? null : username,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
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
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Username (optional)',
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        cursorColor: colors.primary,
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w100,
                        ),
                        decoration: _inputDecoration(
                          colors: colors,
                          hintText: 'Auto-generated when left blank',
                        ),
                      ),
                      const SizedBox(height: 15),
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
                          fontWeight: FontWeight.w100,
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
                        autofillHints: const [AutofillHints.newPassword],
                        onSubmitted: (_) {
                          if (!_isLoading) _register();
                        },
                        cursorColor: colors.primary,
                        style: GoogleFonts.jetBrainsMono(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w100,
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
                            onPressed: _isLoading ? null : _register,
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
                                    'REGISTER',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
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
