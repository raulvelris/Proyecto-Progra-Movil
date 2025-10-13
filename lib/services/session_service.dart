import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserData(String token, String userId, String email) async {
    await _prefs.setString('user_token', token);
    await _prefs.setString('user_id', userId);
    await _prefs.setString('user_email', email);
  }

  String? get userToken => _prefs.getString('user_token');

  String? get userId => _prefs.getString('user_id');

  String? get userEmail => _prefs.getString('user_email');

  bool get isLoggedIn => userToken != null;

  Future<void> logout() async {
    await _prefs.remove('user_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
  }
}