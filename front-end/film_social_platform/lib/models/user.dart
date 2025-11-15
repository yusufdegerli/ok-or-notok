class User {
  final String id;
  final String username;
  final String email;
  final String country;
  final String? avatarUrl;
  final DateTime createdAt;
  final int followersCount;
  final int followingCount;
  final int listsCount;
  final int reviewsCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.country,
    this.avatarUrl,
    required this.createdAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.listsCount = 0,
    this.reviewsCount = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      country: json['country'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      listsCount: json['lists_count'] as int? ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'country': country,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'lists_count': listsCount,
      'reviews_count': reviewsCount,
    };
  }
}
