import 'user.dart';

class Comment {
  final String id;
  final String content;
  final User author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final String? parentId; // For nested comments
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.parentId,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      likesCount: json['likes_count'] as int? ?? 0,
      parentId: json['parent_id'] as String?,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'likes_count': likesCount,
      'parent_id': parentId,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}
