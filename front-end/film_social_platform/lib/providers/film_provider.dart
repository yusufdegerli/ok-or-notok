import 'package:flutter/foundation.dart';
import '../models/film.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class FilmProvider with ChangeNotifier {
  List<Film> _popularFilms = [];
  List<Film> _countryFilms = [];
  List<Film> _allFilms = [];
  Film? _currentFilm;
  List<Comment> _filmComments = [];
  List<User> _popularUsers = [];
  Map<String, List<Film>> _countryFilmsCache = {};

  bool _isLoading = false;
  String? _error;

  List<Film> get popularFilms => _popularFilms;
  List<Film> get countryFilms => _countryFilms;
  List<Film> get allFilms => _allFilms;
  Film? get currentFilm => _currentFilm;
  List<Comment> get filmComments => _filmComments;
  List<User> get popularUsers => _popularUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load popular films with cache
  Future<void> loadPopularFilms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      final cachedFilms = CacheService.getGlobalPopularFilms();
      if (cachedFilms != null && cachedFilms.isNotEmpty) {
        _popularFilms = cachedFilms;
        _isLoading = false;
        notifyListeners();
      }

      // Fetch from API
      final films = await ApiService.getPopularFilms();
      _popularFilms = films;
      await CacheService.cacheGlobalPopularFilms(films);
    } catch (e) {
      _error = e.toString();
      if (_popularFilms.isEmpty) {
        // If no cache, show error
        _error = 'Failed to load popular films';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load country films with cache
  Future<void> loadCountryFilms(String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      final cachedFilms = CacheService.getCountryPopularFilms(country);
      if (cachedFilms != null && cachedFilms.isNotEmpty) {
        _countryFilms = cachedFilms;
        _countryFilmsCache[country] = cachedFilms;
        _isLoading = false;
        notifyListeners();
      }

      // Fetch from API
      final films = await ApiService.getCountryFilms(country);
      _countryFilms = films;
      _countryFilmsCache[country] = films;
      await CacheService.cacheCountryPopularFilms(country, films);
    } catch (e) {
      _error = e.toString();
      if (_countryFilms.isEmpty) {
        _error = 'Failed to load country films';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all films with cache
  Future<void> loadAllFilms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      final cachedFilms = CacheService.getAllFilms();
      if (cachedFilms != null && cachedFilms.isNotEmpty) {
        _allFilms = cachedFilms;
        _isLoading = false;
        notifyListeners();
      }

      // Fetch from API
      final films = await ApiService.getAllFilms();
      _allFilms = films;
      await CacheService.cacheAllFilms(films);
    } catch (e) {
      _error = e.toString();
      if (_allFilms.isEmpty) {
        _error = 'Failed to load all films';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load film detail with cache
  Future<void> loadFilmDetail(String filmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      final cachedFilm = CacheService.getFilmDetail(filmId);
      if (cachedFilm != null) {
        _currentFilm = cachedFilm;
        _isLoading = false;
        notifyListeners();
      }

      // Fetch from API
      final film = await ApiService.getFilmDetail(filmId);
      _currentFilm = film;
      await CacheService.cacheFilmDetail(filmId, film);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load popular users with cache
  Future<void> loadPopularUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check cache first
      final cachedUsers = CacheService.getPopularUsers();
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        _popularUsers = cachedUsers;
        _isLoading = false;
        notifyListeners();
      }

      // Fetch from API
      final users = await ApiService.getPopularUsers();
      _popularUsers = users;
      await CacheService.cachePopularUsers(users);
    } catch (e) {
      _error = e.toString();
      if (_popularUsers.isEmpty) {
        _error = 'Failed to load popular users';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Film actions
  Future<void> likeFilm(String filmId) async {
    try {
      await ApiService.likeFilm(filmId);
      // Invalidate cache and reload
      await CacheService.clearFilmDetail(filmId);
      if (_currentFilm?.id == filmId) {
        await loadFilmDetail(filmId);
      }
      await loadPopularFilms();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> watchFilm(String filmId) async {
    try {
      await ApiService.watchFilm(filmId);
      await CacheService.clearFilmDetail(filmId);
      if (_currentFilm?.id == filmId) {
        await loadFilmDetail(filmId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addToWatchlist(String filmId) async {
    try {
      await ApiService.addToWatchlist(filmId);
      await CacheService.clearFilmDetail(filmId);
      if (_currentFilm?.id == filmId) {
        await loadFilmDetail(filmId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Comments
  Future<void> loadFilmComments(String filmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _filmComments = await ApiService.getFilmComments(filmId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> postFilmComment(String filmId, String content) async {
    try {
      final comment = await ApiService.postFilmComment(filmId, content);
      _filmComments.insert(0, comment);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
