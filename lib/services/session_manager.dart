
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/model/user_model.dart';
import '../features/auth/domain/entities/user_entity.dart';

class SessionManager {
  SessionManager._internal();

  static final SessionManager _instance = SessionManager._internal();
  static SessionManager get instance => _instance;

  final FlutterSecureStorage? _secureStorage = kIsWeb ? null : const FlutterSecureStorage();
  SharedPreferences? _prefs;

  String? userId;
  String? jwtAccessToken;
  String? jwtRefreshToken;
  UserModel? _userModel; // Store as model internally

  final StreamController<String?> _controller = StreamController<String?>.broadcast();
  Stream<String?> get accessTokenStream => _controller.stream;

  // Initialize SharedPreferences for web platform
  Future<void> initialize() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
      // Load tokens from SharedPreferences on web
      jwtAccessToken = _prefs?.getString('jwtAccessToken');
      jwtRefreshToken = _prefs?.getString('jwtRefreshToken');
      userId = _prefs?.getString('userId');

      // Load user model
      final userJson = _prefs?.getString('userModel');
      if (userJson != null && userJson.isNotEmpty) {
        try {
          _userModel = UserModel.fromJson(jsonDecode(userJson));
        } catch (e) {
          print('Error parsing user model: $e');
          _userModel = null;
        }
      }
    } else {
      // Load tokens from secure storage on mobile
      await getSession();
    }
  }

  /// Sets the user session with access and refresh tokens
  Future<void> setSession({
    required String? jwtAccessToken,
    String? jwtRefreshToken,
    String? userId,
    UserEntity? userEntity, // Accept entity from bloc
  }) async {
    this.jwtAccessToken = jwtAccessToken;
    this.jwtRefreshToken = jwtRefreshToken;
    this.userId = userId;

    // Convert entity to model for storage
    if (userEntity != null) {
      _userModel = UserModel(
        id: userEntity.id,
        name: userEntity.name,
        email: userEntity.email,
        phone: userEntity.phone,
        role: userEntity.role,
        isVerified: userEntity.isVerified,
        refreshToken: userEntity.refreshToken,
        accessToken: userEntity.accessToken,
      );
    } else {
      _userModel = null;
    }

    if (kIsWeb) {
      // Store in SharedPreferences for web (persists across sessions)
      await _ensurePrefsInitialized();

      if (jwtAccessToken != null) {
        await _prefs!.setString('jwtAccessToken', jwtAccessToken);
      } else {
        await _prefs!.remove('jwtAccessToken');
      }

      if (jwtRefreshToken != null) {
        await _prefs!.setString('jwtRefreshToken', jwtRefreshToken);
      } else {
        await _prefs!.remove('jwtRefreshToken');
      }

      if (userId != null) {
        await _prefs!.setString('userId', userId);
      } else {
        await _prefs!.remove('userId');
      }

      if (_userModel != null) {
        await _prefs!.setString('userModel', jsonEncode(_userModel!.toJson()));
      } else {
        await _prefs!.remove('userModel');
      }
    } else {
      // Store in secure storage for mobile
      if (jwtAccessToken != null) {
        await _secureStorage!.write(key: "jwtAccessToken", value: jwtAccessToken);
      } else {
        await _secureStorage!.delete(key: "jwtAccessToken");
      }

      if (jwtRefreshToken != null) {
        await _secureStorage!.write(key: "jwtRefreshToken", value: jwtRefreshToken);
      } else {
        await _secureStorage!.delete(key: "jwtRefreshToken");
      }

      if (userId != null) {
        await _secureStorage!.write(key: "userId", value: userId);
      } else {
        await _secureStorage!.delete(key: "userId");
      }

      if (_userModel != null) {
        await _secureStorage!.write(key: "userModel", value: jsonEncode(_userModel!.toJson()));
      } else {
        await _secureStorage!.delete(key: "userModel");
      }
    }

    _controller.add(jwtAccessToken);
  }

  /// Retrieves the session tokens from storage
  Future<void> getSession() async {
    if (kIsWeb) {
      await _ensurePrefsInitialized();
      jwtAccessToken = _prefs?.getString('jwtAccessToken');
      jwtRefreshToken = _prefs?.getString('jwtRefreshToken');
      userId = _prefs?.getString('userId');

      final userJson = _prefs?.getString('userModel');
      if (userJson != null && userJson.isNotEmpty) {
        try {
          _userModel = UserModel.fromJson(jsonDecode(userJson));
        } catch (e) {
          print('Error parsing user model: $e');
          _userModel = null;
        }
      }
    } else {
      jwtAccessToken = await _secureStorage?.read(key: 'jwtAccessToken');
      jwtRefreshToken = await _secureStorage?.read(key: 'jwtRefreshToken');
      userId = await _secureStorage?.read(key: 'userId');

      final userJson = await _secureStorage?.read(key: 'userModel');
      if (userJson != null && userJson.isNotEmpty) {
        try {
          _userModel = UserModel.fromJson(jsonDecode(userJson));
        } catch (e) {
          print('Error parsing user model: $e');
          _userModel = null;
        }
      }
    }
  }

  /// Clears the session tokens from memory and storage
  Future<void> clearSession() async {
    jwtAccessToken = null;
    jwtRefreshToken = null;
    userId = null;
    _userModel = null;

    if (kIsWeb) {
      await _ensurePrefsInitialized();
      await Future.wait([
        _prefs!.remove('jwtAccessToken'),
        _prefs!.remove('jwtRefreshToken'),
        _prefs!.remove('userId'),
        _prefs!.remove('userModel'),
      ]);
    } else {
      await Future.wait([
        _secureStorage!.delete(key: 'jwtAccessToken'),
        _secureStorage!.delete(key: 'jwtRefreshToken'),
        _secureStorage!.delete(key: 'userId'),
        _secureStorage!.delete(key: 'userModel'),
      ]);
    }

    _controller.add(null);
  }

  /// Updates the access token
  Future<void> updateAccessToken(String? token) async {
    await setSession(
      jwtAccessToken: token,
      jwtRefreshToken: jwtRefreshToken,
      userId: userId,
      userEntity: getUserEntity,
    );
  }

  /// Updates the refresh token
  Future<void> updateRefreshToken(String? token) async {
    jwtRefreshToken = token;

    if (kIsWeb) {
      await _ensurePrefsInitialized();
      if (token != null) {
        await _prefs!.setString('jwtRefreshToken', token);
      } else {
        await _prefs!.remove('jwtRefreshToken');
      }
    } else {
      if (token != null) {
        await _secureStorage!.write(key: "jwtRefreshToken", value: token);
      } else {
        await _secureStorage!.delete(key: "jwtRefreshToken");
      }
    }
  }

  // Ensure SharedPreferences is initialized
  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Getters
  String? get getUserId => userId;
  String? get getAccessToken => jwtAccessToken;
  String? get getRefreshToken => jwtRefreshToken;

  // Convert model to entity when accessing
  UserEntity? get getUserEntity {
    if (_userModel == null) return null;
    return _userModel!.toEntity();
  }

  /// Checks if the user is authenticated
  bool isAuthenticated() {
    return jwtAccessToken != null && jwtAccessToken!.isNotEmpty;
  }

  /// Dispose the stream controller
  void dispose() {
    _controller.close();
  }
}