import 'package:hive_flutter/hive_flutter.dart';
import '../models/film.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class CacheService {
  static const String _boxName = 'film_cache';
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // Global Popular Films (12 hours)
  static Future<void> cacheGlobalPopularFilms(List<Film> films) async {
    await _box?.put(
      CacheKeys.globalPopularFilms,
      films.map((f) => f.toJson()).toList(),
    );
    await _box?.put(
      CacheKeys.globalPopularFilmsTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<Film>? getGlobalPopularFilms() {
    final timestamp = _box?.get(CacheKeys.globalPopularFilmsTimestamp) as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = Duration(milliseconds: now - timestamp);

    if (cacheAge > CacheDurations.globalPopularFilms) {
      return null; // Cache expired
    }

    final data = _box?.get(CacheKeys.globalPopularFilms) as List<dynamic>?;
    if (data == null) return null;

    return data
        .map((json) => Film.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Country Popular Films (24 hours)
  static Future<void> cacheCountryPopularFilms(
    String country,
    List<Film> films,
  ) async {
    final key = '${CacheKeys.countryPopularFilms}_$country';
    await _box?.put(key, films.map((f) => f.toJson()).toList());
    await _box?.put(
      '${CacheKeys.countryPopularFilmsTimestamp}_$country',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<Film>? getCountryPopularFilms(String country) {
    final timestampKey = '${CacheKeys.countryPopularFilmsTimestamp}_$country';
    final timestamp = _box?.get(timestampKey) as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = Duration(milliseconds: now - timestamp);

    if (cacheAge > CacheDurations.countryPopularFilms) {
      return null; // Cache expired
    }

    final key = '${CacheKeys.countryPopularFilms}_$country';
    final data = _box?.get(key) as List<dynamic>?;
    if (data == null) return null;

    return data
        .map((json) => Film.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // All Films (7 days)
  static Future<void> cacheAllFilms(List<Film> films) async {
    await _box?.put(CacheKeys.allFilms, films.map((f) => f.toJson()).toList());
    await _box?.put(
      CacheKeys.allFilmsTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<Film>? getAllFilms() {
    final timestamp = _box?.get(CacheKeys.allFilmsTimestamp) as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = Duration(milliseconds: now - timestamp);

    if (cacheAge > CacheDurations.allFilms) {
      return null; // Cache expired
    }

    final data = _box?.get(CacheKeys.allFilms) as List<dynamic>?;
    if (data == null) return null;

    return data
        .map((json) => Film.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Film Detail (1 hour)
  static Future<void> cacheFilmDetail(String filmId, Film film) async {
    final key = '${CacheKeys.filmDetail}$filmId';
    final timestampKey = '${CacheKeys.filmDetailTimestamp}$filmId';
    await _box?.put(key, film.toJson());
    await _box?.put(timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Film? getFilmDetail(String filmId) {
    final timestampKey = '${CacheKeys.filmDetailTimestamp}$filmId';
    final timestamp = _box?.get(timestampKey) as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = Duration(milliseconds: now - timestamp);

    if (cacheAge > CacheDurations.filmDetail) {
      return null; // Cache expired
    }

    final key = '${CacheKeys.filmDetail}$filmId';
    final data = _box?.get(key) as Map<dynamic, dynamic>?;
    if (data == null) return null;

    return Film.fromJson(Map<String, dynamic>.from(data));
  }

  // Popular Users (1 hour)
  static Future<void> cachePopularUsers(List<User> users) async {
    await _box?.put(
      CacheKeys.popularUsers,
      users.map((u) => u.toJson()).toList(),
    );
    await _box?.put(
      CacheKeys.popularUsersTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<User>? getPopularUsers() {
    final timestamp = _box?.get(CacheKeys.popularUsersTimestamp) as int?;
    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = Duration(milliseconds: now - timestamp);

    if (cacheAge > CacheDurations.popularUsers) {
      return null; // Cache expired
    }

    final data = _box?.get(CacheKeys.popularUsers) as List<dynamic>?;
    if (data == null) return null;

    return data
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Clear all cache
  static Future<void> clearCache() async {
    await _box?.clear();
  }

  // Clear specific cache
  static Future<void> clearFilmDetail(String filmId) async {
    final key = '${CacheKeys.filmDetail}$filmId';
    final timestampKey = '${CacheKeys.filmDetailTimestamp}$filmId';
    await _box?.delete(key);
    await _box?.delete(timestampKey);
  }
}
