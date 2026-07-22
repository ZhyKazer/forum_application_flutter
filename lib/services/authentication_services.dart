import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final trimmedUsername = username?.trim();
    final resolvedUsername = trimmedUsername == null || trimmedUsername.isEmpty
        ? _generateUsername(email)
        : trimmedUsername;

    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': resolvedUsername},
      );
    } on AuthException catch (error) {
      throw Exception(error.message);
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      throw Exception(error.message);
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (error) {
      throw Exception(error.message);
    }
  }

  String _generateUsername(String email) {
    final emailName = email.split('@').first.toLowerCase();
    final sanitizedName = emailName.replaceAll(RegExp(r'[^a-z0-9_]'), '');
    final baseName = sanitizedName.isEmpty ? 'user' : sanitizedName;
    final shortenedName = baseName.length > 16
        ? baseName.substring(0, 16)
        : baseName;
    final uniqueSuffix = DateTime.now().microsecondsSinceEpoch.toRadixString(
      36,
    );

    return '${shortenedName}_$uniqueSuffix';
  }
}
