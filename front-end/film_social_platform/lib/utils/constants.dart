class CacheKeys {
  static const String globalPopularFilms = 'global_popular_films';
  static const String countryPopularFilms = 'country_popular_films';
  static const String allFilms = 'all_films';
  static const String filmDetail = 'film_detail_';
  static const String popularUsers = 'popular_users';

  static const String globalPopularFilmsTimestamp = 'global_popular_films_ts';
  static const String countryPopularFilmsTimestamp = 'country_popular_films_ts';
  static const String allFilmsTimestamp = 'all_films_ts';
  static const String filmDetailTimestamp = 'film_detail_ts_';
  static const String popularUsersTimestamp = 'popular_users_ts';
}

class CacheDurations {
  static const Duration globalPopularFilms = Duration(hours: 12);
  static const Duration countryPopularFilms = Duration(hours: 24);
  static const Duration allFilms = Duration(days: 7);
  static const Duration filmDetail = Duration(hours: 1);
  static const Duration popularUsers = Duration(hours: 1);
}

class ApiEndpoints {
  // Flutter için backend URL'i
  // Android Emulator için: http://10.0.2.2:4000/api
  // iOS Simulator için: http://localhost:4000/api
  // Gerçek cihaz için: http://[BILGISAYAR_IP]:4000/api (örn: http://192.168.1.100:4000/api)
  // Web/Linux Desktop için: http://localhost:4000/api
  static const String baseUrl =
      'http://localhost:4000/api'; // Web/Linux Desktop için
  static const String status = '/auth/status';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String popularFilms = '/films/popular';
  static const String countryFilms = '/films/country';
  static const String allFilms = '/films';
  static const String filmDetail = '/films';
  static const String likeFilm = '/films/like';
  static const String watchFilm = '/films/watch';
  static const String addToWatchlist = '/films/watchlist';
  static const String filmComments = '/films/comments';
  static const String userLists = '/lists';
  static const String listComments = '/lists/comments';
  static const String popularUsers = '/users/popular';
}
