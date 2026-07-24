import 'post_images_models.dart';
import 'profile_models.dart';

class PostModel {
  final String postId;
  final String authorId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileModel? author;
  final List<PostImageModel> images;

  PostModel({
    required this.postId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.images = const [],
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    postId: json['post_id'] as String,
    authorId: json['author_id'] as String,
    title: json['post_title'] as String,
    content: json['post_content'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    author: json['profiles'] != null
        ? ProfileModel.fromJson(json['profiles'] as Map<String, dynamic>)
        : null,
    images: ((json['post_images'] as List<dynamic>?) ?? const [])
      .map((image) => PostImageModel.fromJson(image as Map<String, dynamic>))
      .toList()
      ..sort((left, right) => left.displayOrder.compareTo(right.displayOrder)),
  );

  PostModel copyWith({ProfileModel? author}) {
    return PostModel(
      postId: postId,
      authorId: authorId,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      author: author ?? this.author,
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
    'post_id': postId,
    'author_id': authorId,
    'post_title': title,
    'post_content': content,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
