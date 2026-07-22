class ProfileModel {
  final String userId;
  final String? avatarPath;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.userId,
    this.avatarPath,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    userId: json['user_id'] as String,
    avatarPath: json['avatar_path'] as String?,
    username: json['username'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'avatar_path': avatarPath,
    'username': username,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
