import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    final extension = file.path.split('.').last;
    final filePath = '$userId/avatar.$extension';

    await _supabase.storage
        .from('avatars')
        .upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            upsert: true,
          ),
        );

    return filePath;
  }

  String getAvatarUrl(String storagePath) {
    return _supabase.storage
        .from('avatars')
        .getPublicUrl(storagePath);
  }

  Future<void> deleteAvatar(String storagePath) async {
    await _supabase.storage
        .from('avatars')
        .remove([storagePath]);
  }
}