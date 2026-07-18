import 'post_models.dart';
import 'profile_models.dart';

class CommentModel {
  final String commentId;
  final String authorId;
  final String postId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileModel? author;
  final PostModel? post;

  CommentModel({
    required this.commentId, 
    required this.authorId, 
    required this.postId, 
    required this.content, 
    required this.createdAt, 
    required this.updatedAt, 
    this.author, 
    this.post
    });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    commentId: json['comment_id'] as String,
    authorId: json['author_id'] as String,
    postId: json['post_id'] as String,
    content: json['comment_content'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    author: json['profiles'] != null ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>) : null,
    post: json['post'] != null ? PostModel.fromJson(json['post'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'comment_id': commentId, 
    'author_id': authorId, 
    'post_id': postId, 
    'comment_content': content, 
    'created_at': createdAt.toIso8601String(), 
    'updated_at': updatedAt.toIso8601String()
    };
}
