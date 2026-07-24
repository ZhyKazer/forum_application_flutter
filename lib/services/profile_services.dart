import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_models.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileModel?> getMyProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> getProfileById(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateProfile({
    String? username,
    String? avatarPath,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user.');
    }
    if (username == null || username.trim().isEmpty) {
      throw ArgumentError.value(username, 'username', 'A username is required.');
    }

    final data = await _supabase.rpc(
      'upsert_my_profile',
      params: {
        'profile_username': username.trim(),
        'profile_avatar_path': avatarPath,
      },
    );

    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }
}
