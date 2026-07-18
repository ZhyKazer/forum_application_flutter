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

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (username != null) {
      updates['username'] = username;
    }

    if (avatarPath != null) {
      updates['avatar_path'] = avatarPath;
    }

    final data = await _supabase
        .from('profiles')
        .update(updates)
        .eq('user_id', user.id)
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }
}