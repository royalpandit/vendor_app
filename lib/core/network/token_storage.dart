// lib/core/network/token_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vendor_app/features/authentication/data/models/user_model.dart';

/// Token and user data storage with SharedPreferences persistence.
/// Token and user info are saved to disk so users stay logged in across app restarts.
/// Only the auth token/user are persisted; API responses (bookings, leads, etc.) are NOT cached.

class TokenStorage {
  static const _kToken = 'auth_token';
  static const _kUserId = 'user_id';
  static const _kUserName = 'user_name';
  static const _kUserEmail = 'user_email';
  static const _kUserPhone = 'user_phone';
  static const _kUserRoles = 'user_roles';

  /// Save token and user data to SharedPreferences.
  static Future<void> saveTokenAndUserData({
    required String token,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kToken, token);
      await prefs.setInt(_kUserId, user.id ?? 0);
      await prefs.setString(_kUserName, user.name);
      await prefs.setString(_kUserEmail, user.email ?? '');
      await prefs.setString(_kUserPhone, user.phone);
      await prefs.setStringList(_kUserRoles, user.roles);
    } catch (e) {
      // Log error if needed
    }
  }

  /// Get token from SharedPreferences.
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kToken);
    } catch (e) {
      return null;
    }
  }

  /// Get user data from SharedPreferences.
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(_kUserId);
      final name = prefs.getString(_kUserName);
      final email = prefs.getString(_kUserEmail);
      final phone = prefs.getString(_kUserPhone);
      final roles = prefs.getStringList(_kUserRoles);

      if (id != null && name != null && phone != null && roles != null) {
        return UserModel(
          id: id,
          name: name,
          email: email ?? '',
          phone: phone,
          roles: roles,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear all stored authentication data.
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
      // Log error if needed
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



