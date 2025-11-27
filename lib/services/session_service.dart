import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUserData(
    String token,
    String userId,
    String email, {
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    await _prefs.setString('user_token', token);
    await _prefs.setString('user_id', userId);
    await _prefs.setString('user_email', email);
    if (firstName != null) await _prefs.setString('user_first_name', firstName);
    if (lastName != null) await _prefs.setString('user_last_name', lastName);
    if (profilePicture != null) {
      await _prefs.setString('user_profile_picture', profilePicture);
    }
  }

  String? get userToken => _prefs.getString('user_token');

  String? get userId => _prefs.getString('user_id');

  String? get userEmail => _prefs.getString('user_email');

  String? get userFirstName => _prefs.getString('user_first_name');

  String? get userLastName => _prefs.getString('user_last_name');

  String? get userProfilePicture => _prefs.getString('user_profile_picture');

  bool get isLoggedIn => userToken != null;

  Future<void> logout() async {
    await _prefs.remove('user_token');
    await _prefs.remove('user_id');
    await _prefs.remove('user_email');
    await _prefs.remove('user_first_name');
    await _prefs.remove('user_last_name');
    await _prefs.remove('user_profile_picture');
  }
}