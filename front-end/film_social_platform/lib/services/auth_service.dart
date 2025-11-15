// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // REGISTER
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String country,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.register}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'country': country,
      }),
    );

    // Accept both 200 and 201 as success depending on backend implementation
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      // Eğer backend token döndürüyorsa kaydet
      if (body is Map && body.containsKey('token')) {
        await saveToken(body['token']);
      }
      return {'success': true, 'data': body};
    } else {
      final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      return {'success': false, 'message': error['error'] ?? error['message'] ?? 'Register failed'};
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        // Eğer token döndüyse kaydet
        if (data is Map && data.containsKey('token')) {
          await saveToken(data['token']);
          // ApiService'e de token'ı set et
          ApiService.setAuthToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {'success': false, 'message': error['error'] ?? error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // SAVE TOKEN
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token', token); // getToken() için de kaydet
  }

  // GET TOKEN
  /*
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  */

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // IS LOGGED IN
    // CHECK IF USER IS LOGGED IN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  // GET STORED TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET CURRENT USER
  // Öncelikle backend'de /api/auth/me (veya benzeri) endpoint'inin olmasını dener.
  // Eğer yoksa token'ı decode edip içinden user bilgisi çıkarır (payload varsa).
  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    // 1) Deneme: backend'de /api/auth/me varsa çağır
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/auth/me');
      final resp = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (resp.statusCode == 200 && resp.body.isNotEmpty) {
        final body = jsonDecode(resp.body);
        // Burada backend'in döndürdüğü user nesnesinin yapısına göre özelleştir
        return _mapToUser(body['user'] ?? body);
      }
    } catch (_) {
      // ignore and fallback to token decode
    }

    // 2) Fallback: token içinden payload decode et (eğer payload user info içeriyorsa)
    try {
      final payload = _decodeJwtPayload(token);
      if (payload != null) {
        // payload içindeki alan isimleri backend'e göre değişir; örnek alalım:
        final id = payload['id'] ?? payload['user_id'] ?? payload['sub'];
        final username = payload['username'] ?? payload['name'];
        final email = payload['email'];
        final country = payload['country'] ?? null;
        if (id != null && username != null) {
          return User(
            id: (id is int ? id : int.tryParse(id.toString()) ?? 0).toString(),
            username: username.toString(),
            email: email?.toString() ?? '',
            country: country?.toString() ?? '',
            createdAt: DateTime.now()
          );
        }
      }
    } catch (_) {
      // ignore
    }

    return null;
  }

  // ---------- Helpers ----------

  User _mapToUser(Map<String, dynamic> data) {
  // CreatedAt için fallback: şimdi veya verideki created_at tarihini DateTime.parse ile oluştur
  DateTime createdAt;
  try {
    final createdRaw = data['created_at'] ?? data['createdAt'] ?? DateTime.now().toIso8601String();
    createdAt = DateTime.tryParse(createdRaw.toString()) ?? DateTime.now();
  } catch (e) {
    createdAt = DateTime.now();
  }

  // country alanı modelinde farklı adlandırılmış olabilir; fallback empty string
  final countryVal = data['country'] ?? data['location'] ?? data['country_name'] ?? '';

  return User(
    id: data['id'] is int ? data['id'] : int.tryParse(data['id']?.toString() ?? '0') ?? 0,
    username: data['username'] ?? data['name'] ?? '',
    email: data['email'] ?? '',
    // Eğer User modelin createdAt parametresi adını createdAt olarak istiyorsa:
    createdAt: createdAt,
    // Eğer model country parametresi farklı ise bu satır hata verir — devamında alternatif var
    country: countryVal,
  );
}


  Map<String, dynamic>? _decodeJwtPayload(String token) {
    // JWT = header.payload.signature
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = parts[1];

    // base64Url decode (normalize padding)
    var normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final Map<String, dynamic> map = jsonDecode(decoded);
    return map;
  }
}
