import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../features/auth/data/models/user_model.dart';

abstract class BaseAuthRepository {
  UserModel? get currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<UserModel?> signUp(String displayName, String email, String password);
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateEmpathyPoints(int points);
  Future<void> updateStreak(int streak, String date);
  Stream<UserModel?> get onAuthStateChanged;
}

// TRIỂN KHAI MOCK REPOSITORY (Chạy offline lập tức)
class MockAuthRepository extends BaseAuthRepository {
  UserModel? _currentUser;
  
  // Tạo StreamController để mô phỏng thay đổi trạng thái đăng nhập
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Stream<UserModel?> get onAuthStateChanged => _authStateController.stream;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Giả lập mạng
    _currentUser = UserModel(
      uid: 'mock_user_123',
      email: email,
      displayName: email.split('@')[0].toUpperCase(),
      empathyPoints: 10,
      streak: 1,
      lastRitualDate: null,
      avatarSymbol: 'Lotus',
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<UserModel?> signUp(String displayName, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      uid: 'mock_user_123',
      email: email,
      displayName: displayName,
      empathyPoints: 0,
      streak: 0,
      lastRitualDate: null,
      avatarSymbol: 'Lotus',
    );
    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Future<void> updateEmpathyPoints(int points) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        empathyPoints: _currentUser!.empathyPoints + points,
      );
      _authStateController.add(_currentUser);
    }
  }

  @override
  Future<void> updateStreak(int streak, String date) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        streak: streak,
        lastRitualDate: date,
      );
      _authStateController.add(_currentUser);
    }
  }

  void dispose() {
    _authStateController.close();
  }
}

// TRIỂN KHAI FIREBASE AUTH REPOSITORY THẬT
class FirebaseAuthRepository extends BaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();

  FirebaseAuthRepository() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _currentUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Ẩn danh',
          empathyPoints: 0, // Sẽ lấy từ Firestore thông qua DatabaseRepository
          streak: 0,
          lastRitualDate: null,
        );
      } else {
        _currentUser = null;
      }
      _authStateController.add(_currentUser);
    });
  }

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Stream<UserModel?> get onAuthStateChanged => _authStateController.stream;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        _currentUser = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName ?? 'Ẩn danh',
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      debugPrint("Lỗi đăng nhập Repository: $e");
      rethrow;
    }
    return null;
  }

  @override
  Future<UserModel?> signUp(String displayName, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        _currentUser = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: displayName,
        );
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      debugPrint("Lỗi đăng ký Repository: $e");
      rethrow;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Lỗi gửi email reset password: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateEmpathyPoints(int points) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        empathyPoints: _currentUser!.empathyPoints + points,
      );
      _authStateController.add(_currentUser);
    }
  }

  @override
  Future<void> updateStreak(int streak, String date) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        streak: streak,
        lastRitualDate: date,
      );
      _authStateController.add(_currentUser);
    }
  }
}
