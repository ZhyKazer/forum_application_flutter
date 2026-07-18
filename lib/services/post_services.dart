import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_models.dart';

class PostService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PostModel>> getPosts() async {
    final data = await _supabase
        .from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return data
        .map<PostModel>((json) => PostModel.fromJson(json))
        .toList();
  }

  Future<PostModel> getPostById(String postId) async {
    final data = await _supabase
        .from('posts')
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
        .from('posts')
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
        .from('posts')
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
    await _supabase
        .from('posts')
        .delete()
        .eq('post_id', postId);
  }
}