import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationService {
  static const _usernameCombinationsAsset =
      'assets/data/username_combinations.json';
  static Future<_UsernameParts>? _usernameParts;

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
        ? await _generateUsername()
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

  Future<String> _generateUsername() async {
    final parts = await (_usernameParts ??= _loadUsernameParts());
    final random = Random();
    final firstIndex = random.nextInt(parts.words.length);
    var secondIndex = random.nextInt(parts.words.length - 1);
    if (secondIndex >= firstIndex) secondIndex++;
    final firstWord = parts.words[firstIndex];
    final secondWord = parts.words[secondIndex];
    final number = random.nextInt(10000).toString().padLeft(4, '0');

    return '$firstWord$secondWord$number';
  }

  Future<_UsernameParts> _loadUsernameParts() async {
    final text = await rootBundle.loadString(_usernameCombinationsAsset);
    final json = jsonDecode(text) as Map<String, dynamic>;
    final words = List<String>.from(json['username_words'] as List<dynamic>)
        .map(_capitalizeWord)
        .toList();

    if (words.length < 2) {
      throw StateError('Username combinations must include at least two words.');
    }

    return _UsernameParts(words: words);
  }

  String _capitalizeWord(String word) {
    return word.isEmpty
        ? word
        : '${word[0].toUpperCase()}${word.substring(1)}';
  }
}

class _UsernameParts {
  const _UsernameParts({required this.words});

  final List<String> words;
}