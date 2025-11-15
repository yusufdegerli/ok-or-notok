class Film {
  final String id;
  final String title;
  final String? originalTitle;
  final String? description;
  final String? posterUrl;
  final String? backdropUrl;
  final DateTime? releaseDate;
  final int? duration; // minutes
  final double? rating;
  final int likesCount;
  final int watchedCount;
  final int watchlistCount;
  final List<String> genres;
  final List<String> countries;
  final String? director;
  final List<String> cast;

  Film({
    required this.id,
    required this.title,
    this.originalTitle,
    this.description,
    this.posterUrl,
    this.backdropUrl,
    this.releaseDate,
    this.duration,
    this.rating,
    this.likesCount = 0,
    this.watchedCount = 0,
    this.watchlistCount = 0,
    this.genres = const [],
    this.countries = const [],
    this.director,
    this.cast = const [],
  });

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] as String,
      title: json['title'] as String,
      originalTitle: json['original_title'] as String?,
      description: json['description'] as String?,
      posterUrl: json['poster_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      duration: json['duration'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      likesCount: json['likes_count'] as int? ?? 0,
      watchedCount: json['watched_count'] as int? ?? 0,
      watchlistCount: json['watchlist_count'] as int? ?? 0,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      countries:
          (json['countries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      director: json['director'] as String?,
      cast:
          (json['cast'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'original_title': originalTitle,
      'description': description,
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'release_date': releaseDate?.toIso8601String(),
      'duration': duration,
      'rating': rating,
      'likes_count': likesCount,
      'watched_count': watchedCount,
      'watchlist_count': watchlistCount,
      'genres': genres,
      'countries': countries,
      'director': director,
      'cast': cast,
    };
  }
}
