import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film.dart';
import '../models/user.dart';
import '../models/comment.dart';
import '../models/film_list.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = ApiEndpoints.baseUrl;
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Auth
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.login}'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<bool> checkConnection() async{
    try{
      final response = await http.get(
        Uri.parse('$baseUrl${ApiEndpoints.status}'),
        headers: _headers,
      );

      if (response.statusCode == 200){
        print("API ve PostgreSQL Bağlantisi!");
        return true;
      }else{
        print('API Hata bildirdi: ${response.statusCode} - ${response.body}');
        return false;
      }
    }catch(e) {
      print('Bağlantı hatası: checkConnection func: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String username,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.register}'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Films
  static Future<List<Film>> getPopularFilms() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.popularFilms}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final films = data['films'] as List<dynamic>;
      return films
          .map((json) => Film.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load popular films: ${response.body}');
    }
  }

  static Future<List<Film>> getCountryFilms(String country) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.countryFilms}/$country'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final films = data['films'] as List<dynamic>;
      return films
          .map((json) => Film.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load country films: ${response.body}');
    }
  }

  static Future<List<Film>> getAllFilms() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.allFilms}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final films = data['films'] as List<dynamic>;
      return films
          .map((json) => Film.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load all films: ${response.body}');
    }
  }

  static Future<Film> getFilmDetail(String filmId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.filmDetail}/$filmId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Film.fromJson(data['film'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load film detail: ${response.body}');
    }
  }

  static Future<void> likeFilm(String filmId) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.likeFilm}/$filmId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to like film: ${response.body}');
    }
  }

  static Future<void> watchFilm(String filmId) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.watchFilm}/$filmId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to mark film as watched: ${response.body}');
    }
  }

  static Future<void> addToWatchlist(String filmId) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.addToWatchlist}/$filmId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add to watchlist: ${response.body}');
    }
  }

  // Comments
  static Future<List<Comment>> getFilmComments(String filmId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.filmComments}/$filmId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final comments = data['comments'] as List<dynamic>;
      return comments
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load comments: ${response.body}');
    }
  }

  static Future<Comment> postFilmComment(String filmId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.filmComments}/$filmId'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return Comment.fromJson(data['comment'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to post comment: ${response.body}');
    }
  }

  // Lists
  static Future<List<FilmList>> getUserLists(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.userLists}?user_id=$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final lists = data['lists'] as List<dynamic>;
      return lists
          .map((json) => FilmList.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load lists: ${response.body}');
    }
  }

  static Future<FilmList> createList(
    String title,
    String? description,
    bool isPublic,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiEndpoints.userLists}'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'is_public': isPublic,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return FilmList.fromJson(data['list'] as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create list: ${response.body}');
    }
  }

  static Future<List<Comment>> getListComments(String listId) async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.listComments}/$listId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final comments = data['comments'] as List<dynamic>;
      return comments
          .map((json) => Comment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load list comments: ${response.body}');
    }
  }

  // Users
  static Future<List<User>> getPopularUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl${ApiEndpoints.popularUsers}'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final users = data['users'] as List<dynamic>;
      return users
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load popular users: ${response.body}');
    }
  }
}
