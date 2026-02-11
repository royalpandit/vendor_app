
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/features/authentication/data/models/user_model.dart';
class SharedPreferencesService {
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userPhoneKey = 'userPhone';
  static const _userRoleKey = 'userRole';
  static const _authTokenKey = 'authToken';

  // Save user data to SharedPreferences
  static Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userIdKey, id);
    prefs.setString(_userNameKey, name);
    prefs.setString(_userEmailKey, email);
    prefs.setString(_userPhoneKey, phone);
    prefs.setString(_userRoleKey, role);
    prefs.setString(_authTokenKey, token);
  }

  // Get user data from SharedPreferences and return a UserModel
  static Future<UserModel> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userData = {
      'id': prefs.getString(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
      'role': prefs.getString(_userRoleKey),
      'token': prefs.getString(_authTokenKey),
    };

    return UserModel.fromJson(userData); // Convert map to UserModel
  }

  // Check if user is already logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    return userId != null;
  }

  // Clear user data from SharedPreferences (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userIdKey);
    prefs.remove(_userNameKey);
    prefs.remove(_userEmailKey);
    prefs.remove(_userPhoneKey);
    prefs.remove(_userRoleKey);
    prefs.remove(_authTokenKey);
  }
}

/*class SharedPreferencesService {
  static const _userIdKey = 'userId';
  static const _userNameKey = 'userName';
  static const _userEmailKey = 'userEmail';
  static const _userPhoneKey = 'userPhone';
  static const _userRoleKey = 'userRole';
  static const _authTokenKey = 'authToken';

  // Save user data to SharedPreferences
  static Future<void> saveUserData({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String role,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userIdKey, id);
    prefs.setString(_userNameKey, name);
    prefs.setString(_userEmailKey, email);
    prefs.setString(_userPhoneKey, phone);
    prefs.setString(_userRoleKey, role);
    prefs.setString(_authTokenKey, token);
  }

  // Get user data from SharedPreferences
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
      'role': prefs.getString(_userRoleKey),
      'token': prefs.getString(_authTokenKey),
    };
  }

  // Check if user is already logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    return userId != null;
  }

  // Clear user data from SharedPreferences (logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_userIdKey);
    prefs.remove(_userNameKey);
    prefs.remove(_userEmailKey);
    prefs.remove(_userPhoneKey);
    prefs.remove(_userRoleKey);
    prefs.remove(_authTokenKey);
  }
}*/
