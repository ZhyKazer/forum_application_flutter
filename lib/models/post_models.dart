import 'profile_models.dart';

class PostModel {
  final String postId;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileModel? author;

  PostModel({
    required this.postId, 
    required this.authorId, 
    required this.title, 
    required this.content, 
    required this.createdAt, 
    required this.updatedAt, 
    this.author});

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    postId: json['post_id'] as String,
    authorId: json['author_id'] as String,
    title: json['post_title'] as String,
    content: json['post_content'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    author: json['profiles'] != null ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'post_id': postId, 
    'author_id': authorId, 
    'post_title': title, 
    'post_content': content, 
    'created_at': createdAt.toIso8601String(), 
    'updated_at': updatedAt.toIso8601String()};
}
