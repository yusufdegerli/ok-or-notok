import 'film.dart';
import 'user.dart';

class FilmList {
  final String id;
  final String title;
  final String? description;
  final User creator;
  final List<Film> films;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isPublic;

  FilmList({
    required this.id,
    required this.title,
    this.description,
    required this.creator,
    this.films = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isPublic = true,
  });

  factory FilmList.fromJson(Map<String, dynamic> json) {
    return FilmList(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      creator: User.fromJson(json['creator'] as Map<String, dynamic>),
      films:
          (json['films'] as List<dynamic>?)
              ?.map((e) => Film.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      isPublic: json['is_public'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creator': creator.toJson(),
      'films': films.map((f) => f.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_public': isPublic,
    };
  }
}
