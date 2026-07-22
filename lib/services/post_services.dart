import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_models.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches one page of posts. The range end is inclusive.
  Future<List<PostModel>> getPosts({int offset = 0, int limit = 10}) async {
    if (offset < 0 || limit < 1) {
      throw ArgumentError(
        'offset must be positive and limit must be at least 1.',
      );
    }

    final data = await _supabase
        .from('post')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .order('post_id', ascending: false)
        .range(offset, offset + limit - 1);

    return data.map<PostModel>((json) => PostModel.fromJson(json)).toList();
  }

  Future<PostModel> getPostById(String postId) async {
    final data = await _supabase
        .from('post')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .single();

    return PostModel.fromJson(data);
  }

  Future<PostModel> createPost({
    required String title,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to create a post.');
    }

    final data = await _supabase
        .from('post')
        .insert({
          'author_id': user.id,
          'post_title': title,
          'post_content': content,
        })
        .select('*, profiles(*)')
        .single();

    return PostModel.fromJson(data);
  }

  Future<PostModel> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    final data = await _supabase
        .from('post')
        .update({
          'post_title': title,
          'post_content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('post_id', postId)
        .select('*, profiles(*)')
        .single();

    return PostModel.fromJson(data);
  }

  Future<void> deletePost(String postId) async {
    await _supabase.from('post').delete().eq('post_id', postId);
  }
}
