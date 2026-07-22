class CommentImageModel {
  final String id;
  final String commentId;
  final String storagePath;
  final int displayOrder;
  final DateTime createdAt;

  CommentImageModel({
    required this.id,
    required this.commentId,
    required this.storagePath,
    required this.displayOrder,
    required this.createdAt,
  });

  factory CommentImageModel.fromJson(Map<String, dynamic> json) =>
      CommentImageModel(
        id: json['id'] as String,
        commentId: json['comment_id'] as String,
        storagePath: json['storage_path'] as String,
        displayOrder: json['display_order'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'comment_id': commentId,
    'storage_path': storagePath,
    'display_order': displayOrder,
    'created_at': createdAt.toIso8601String(),
  };
}
