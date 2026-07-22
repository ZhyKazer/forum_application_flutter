import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_models.dart';

class CommentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CommentModel>> getCommentsByPostId(String postId) async {
    final data = await _supabase
        .from('comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return data
        .map<CommentModel>((json) => CommentModel.fromJson(json))
        .toList();
  }

  Future<CommentModel> createComment({
    required String postId,
    required String content,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('You must be logged in to comment.');
    }

    final data = await _supabase
        .from('comments')
        .insert({
          'author_id': user.id,
          'post_id': postId,
          'comment_content': content,
        })
        .select('*, profiles(*)')
        .single();

    return CommentModel.fromJson(data);
  }

  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    final data = await _supabase
        .from('comments')
        .update({
          'comment_content': content,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('comment_id', commentId)
        .select('*, profiles(*)')
        .single();

    return CommentModel.fromJson(data);
  }

  Future<void> deleteComment(String commentId) async {
    await _supabase.from('comments').delete().eq('comment_id', commentId);
  }
}
