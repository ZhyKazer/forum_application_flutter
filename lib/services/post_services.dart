import 'package:cross_file/cross_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_models.dart';
import '../models/profile_models.dart';

class PostService {
  static const _postImagesBucket = 'post-images';

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
        .select('*, post_images(*)')
        .order('created_at', ascending: false)
        .order('post_id', ascending: false)
        .range(offset, offset + limit - 1);

    return _attachAuthors(data);
  }

  Future<PostModel> getPostById(String postId) async {
    final data = await _supabase
        .from('post')
        .select('*, post_images(*)')
        .eq('post_id', postId)
        .single();

    return (await _attachAuthors([data])).single;
  }

  Future<PostModel> createPost({
    required String title,
    required String content,
    List<XFile> images = const [],
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
        .select('*, post_images(*)')
        .single();

    final post = PostModel.fromJson(data);
    final uploadedPaths = <String>[];

    try {
      for (var index = 0; index < images.length; index++) {
        final image = images[index];
        final extension = image.name.split('.').last.toLowerCase();
        final path = '${user.id}/${post.postId}/${index + 1}.$extension';

        await _supabase.storage.from(_postImagesBucket).uploadBinary(
              path,
              await image.readAsBytes(),
              fileOptions: FileOptions(
                contentType: _imageContentType(extension),
              ),
            );
        uploadedPaths.add(path);

        await _supabase.from('post_images').insert({
          'post_id': post.postId,
          'storage_path': path,
          'display_order': index,
        });
      }
    } catch (error) {
      if (uploadedPaths.isNotEmpty) {
        await _supabase.storage.from(_postImagesBucket).remove(uploadedPaths);
      }
      await _supabase.from('post').delete().eq('post_id', post.postId);
      throw Exception('Could not upload post images: $error');
    }

    return getPostById(post.postId);
  }

  Future<List<PostModel>> _attachAuthors(Iterable<dynamic> data) async {
    final posts = data
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
    final authorIds = posts.map((post) => post.authorId).toSet().toList();

    if (authorIds.isEmpty) return posts;

    final profilesData = await _supabase.rpc(
      'get_post_authors',
      params: {'author_ids': authorIds},
    );
    final profilesById = <String, ProfileModel>{
      for (final json in profilesData)
        (json['user_id'] as String): ProfileModel.fromJson(json),
    };

    return posts
        .map((post) => post.copyWith(author: profilesById[post.authorId]))
        .toList();
  }

  Future<String> getPostImageUrl(String storagePath) {
    return _supabase.storage
        .from(_postImagesBucket)
        .createSignedUrl(storagePath, 60 * 60);
  }

  String _imageContentType(String extension) {
    return extension == 'jpg' ? 'image/jpeg' : 'image/$extension';
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
        .select('*, post_images(*)')
        .single();

    return (await _attachAuthors([data])).single;
  }

  Future<void> deletePost(String postId) async {
    await _supabase.from('post').delete().eq('post_id', postId);
  }
}
