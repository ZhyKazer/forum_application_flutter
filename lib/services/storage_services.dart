import 'package:cross_file/cross_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static const _avatarsBucket = 'avatars';

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadAvatar({
    required XFile image,
    required String userId,
  }) async {
    final extension = image.name.split('.').last.toLowerCase();
    final filePath = '$userId/avatar.$extension';

    await _supabase.storage.from(_avatarsBucket).uploadBinary(
          filePath,
          await image.readAsBytes(),
          fileOptions: FileOptions(
            upsert: true,
            contentType: extension == 'jpg' ? 'image/jpeg' : 'image/$extension',
          ),
        );

    return filePath;
  }

  String getAvatarUrl(String storagePath) {
    return _supabase.storage.from(_avatarsBucket).getPublicUrl(storagePath);
  }

  Future<void> deleteAvatar(String storagePath) async {
    await _supabase.storage.from(_avatarsBucket).remove([storagePath]);
  }
}