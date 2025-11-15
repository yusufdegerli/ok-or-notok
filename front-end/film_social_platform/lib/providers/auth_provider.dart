import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService(); // ✅ instance oluşturduk

  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    // Bu fonksiyonları AuthService içine ekleyeceğiz (getToken, isLoggedIn vs.)
    _isAuthenticated = await AuthService.isLoggedIn();
    if (_isAuthenticated) {
      _user = await _authService.getCurrentUser();
      }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    final success = result['success'] == true;
    if (success) {
      _isAuthenticated = true;
      _user = await _authService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> register(String username, String email, String password, String country) async {
  _isLoading = true;
  notifyListeners();

  final result = await _authService.register(
    username: username,
    email: email,
    password: password,
    country: country,
  );

  final success = result['success'] == true;
  if (success) {
    _isAuthenticated = true;
    _user = await _authService.getCurrentUser();
  }

  _isLoading = false;
  notifyListeners();
  return success;
}

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
