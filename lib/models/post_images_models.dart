class PostImageModel {
  final String id;
  final String postId;
  final String storagePath;
  final int displayOrder;
  final DateTime createdAt;

  PostImageModel({
    required this.id, 
    required this.postId, 
    required this.storagePath, 
    required this.displayOrder, 
    required this.createdAt
    });

  factory PostImageModel.fromJson(Map<String, dynamic> json) => PostImageModel(
    id: json['id'] as String, 
    postId: json['post_id'] as String, 
    storagePath: json['storage_path'] as String, 
    displayOrder: json['display_order'] as int, 
    createdAt: DateTime.parse(json['created_at'] as String
    ));

  Map<String, dynamic> toJson() => {
    'id': id, 
    'post_id': postId, 
    'storage_path': storagePath, 
    'display_order': displayOrder, 
    'created_at': createdAt.toIso8601String()};
}
