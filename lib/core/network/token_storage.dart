// lib/core/storage/token_storage.dart
 import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/features/authentication/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserRoles = 'user_roles';

  // Save token and user data
  static Future<void> saveTokenAndUserData({
    required String token,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save token
      await prefs.setString(_kToken, token);

      // Save user data
      await prefs.setInt(_kUserId, user.id ?? 0);  // Save 0 if id is null
      await prefs.setString(_kUserName, user.name);
      await prefs.setString(_kUserEmail, user.email ?? ''); // Save empty string if email is null
      await prefs.setString(_kUserPhone, user.phone);
      await prefs.setStringList(_kUserRoles, user.roles);
    } catch (e) {
      print("Error saving token and user data: $e");
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kToken);
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve user data
      final id = prefs.getInt(_kUserId);  // id can be null or a valid number
      final name = prefs.getString(_kUserName);
      final email = prefs.getString(_kUserEmail);
      final phone = prefs.getString(_kUserPhone);
      final roles = prefs.getStringList(_kUserRoles);

      if (id != null && name != null && phone != null && roles != null) {
        // If data is complete, return the UserModel
        return UserModel(
          id: id,  // Use the id, which can be null or a valid number
          name: name,
          email: email ?? '', // If email is null, use empty string
          phone: phone,
          roles: roles,
        );
      }
      return null;  // Return null if any of the required fields are missing
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Clear token and user data
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUserId);
      await prefs.remove(_kUserName);
      await prefs.remove(_kUserEmail);
      await prefs.remove(_kUserPhone);
      await prefs.remove(_kUserRoles);
    } catch (e) {
      print("Error clearing data: $e");
    }
  }
}


/*class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserRoles = 'user_roles';

  // Save token and user data
  static Future<void> saveTokenAndUserData({
    required String token,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save token
      await prefs.setString(_kToken, token);

      // Save user data
      await prefs.setInt(_kUserId, user.id);
      await prefs.setString(_kUserName, user.name);
      await prefs.setString(_kUserEmail, user.email ?? ''); // Save empty string if email is null
      await prefs.setString(_kUserPhone, user.phone);
      await prefs.setStringList(_kUserRoles, user.roles);
    } catch (_) {
      // Ignore errors for now
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kToken);
    } catch (_) {
      return null;
    }
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final id = prefs.getInt(_kUserId);
      final name = prefs.getString(_kUserName);
      final email = prefs.getString(_kUserEmail);
      final phone = prefs.getString(_kUserPhone);
      final roles = prefs.getStringList(_kUserRoles);

      if (id != null && name != null && phone != null && roles != null) {
        // Use empty string for null email
        return UserModel(
          id: id,
          name: name,
          email: email, // Can be null
          phone: phone,
          roles: roles,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Clear token and user data
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUserId);
      await prefs.remove(_kUserName);
      await prefs.remove(_kUserEmail);
      await prefs.remove(_kUserPhone);
      await prefs.remove(_kUserRoles);
    } catch (_) {
      // Ignore errors
    }
  }
}*/


/*class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserRoles = 'user_roles';

  // Save token and user data
  static Future<void> saveTokenAndUserData({
    required String token,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save token
      await prefs.setString(_kToken, token);

      // Save user data
      await prefs.setInt(_kUserId, user.id);
      await prefs.setString(_kUserName, user.name);
      await prefs.setString(_kUserEmail, user.email);
      await prefs.setString(_kUserPhone, user.phone);
      await prefs.setStringList(_kUserRoles, user.roles);
    } catch (_) {
      // Ignore errors for now
    }
  }

  // Get token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kToken);
    } catch (_) {
      return null;
    }
  }

  // Get user data
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final id = prefs.getInt(_kUserId);
      final name = prefs.getString(_kUserName);
      final email = prefs.getString(_kUserEmail);
      final phone = prefs.getString(_kUserPhone);
      final roles = prefs.getStringList(_kUserRoles);

      if (id != null && name != null && email != null && phone != null && roles != null) {
        return UserModel(
          id: id,
          name: name,
          email: email,
          phone: phone,
          roles: roles,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Clear token and user data
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kToken);
      await prefs.remove(_kUserId);
      await prefs.remove(_kUserName);
      await prefs.remove(_kUserEmail);
      await prefs.remove(_kUserPhone);
      await prefs.remove(_kUserRoles);
    } catch (_) {
      // Ignore errors
    }
  }
}*/


/*class TokenStorage {
  static const _k = 'auth_token';

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_k, token);
    } catch (_) {*//* ignore *//*}
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_k);
    } catch (_) { return null; }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_k);
    } catch (_) {*//* ignore *//*}
  }
}*/



