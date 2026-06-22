import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/confessional/data/models/confession_model.dart';
import '../../features/daily_ritual/data/models/ritual_model.dart';
import '../../features/auth/data/models/user_model.dart';

abstract class BaseDatabaseRepository {
  Future<void> init();
  Future<List<ConfessionModel>> fetchConfessions();
  Future<ConfessionModel> addConfession(String content);
  Future<ConfessionModel?> sendVirtualHug(String confessionId, String senderUid);
  Future<RitualModel?> fetchTodayRitual(String uid, String date);
  Future<RitualModel> completeTodayRitual(String uid, String date, String affirmation, String microOfferingId, String intention);
  Future<UserModel> fetchSpiritualProfile(String uid);
  Future<void> updateSpiritualAvatar(String uid, String symbol);
}

// TRIỂN KHAI MOCK DATABASE REPOSITORY (Lưu SharedPreferences offline)
class MockDatabaseRepository extends BaseDatabaseRepository {
  List<ConfessionModel> _confessions = [];
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<ConfessionModel>> fetchConfessions() async {
    final rawList = _prefs.getStringList('mock_confessions') ?? [];
    if (rawList.isEmpty) {
      _confessions = [
        ConfessionModel(
          id: 'c1',
          content: "Tôi thấy áp lực kinh khủng từ kỳ vọng của bố mẹ. Nhiều lúc chỉ muốn biến mất...",
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          hugCount: 12,
          supportedUserUids: const ['user_x'],
        ),
        ConfessionModel(
          id: 'c2',
          content: "Đã 3 tháng thất nghiệp rồi. Cảm thấy bản thân thật vô dụng, không bằng bạn bè cùng trang lứa.",
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          hugCount: 24,
          supportedUserUids: const [],
        ),
        ConfessionModel(
          id: 'c3',
          content: "Hôm nay làm vỡ cái cốc của đồng nghiệp nhưng không dám nhận. Thấy tội lỗi và hèn nhát quá.",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          hugCount: 5,
          supportedUserUids: const [],
        ),
      ];
      await _saveConfessionsToPrefs();
    } else {
      _confessions = rawList.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return ConfessionModel(
          id: decoded['id'],
          content: decoded['content'],
          timestamp: DateTime.parse(decoded['timestamp']),
          hugCount: decoded['hugCount'],
          supportedUserUids: List<String>.from(decoded['supportedUserUids'] ?? []),
          isBurned: decoded['isBurned'] ?? false,
        );
      }).toList();
      _confessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return _confessions;
  }

  Future<void> _saveConfessionsToPrefs() async {
    final listToSave = _confessions.map((c) => jsonEncode({
      'id': c.id,
      'content': c.content,
      'timestamp': c.timestamp.toIso8601String(),
      'hugCount': c.hugCount,
      'supportedUserUids': c.supportedUserUids,
      'isBurned': c.isBurned,
    })).toList();
    await _prefs.setStringList('mock_confessions', listToSave);
  }

  @override
  Future<ConfessionModel> addConfession(String content) async {
    final newConf = ConfessionModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      timestamp: DateTime.now(),
      hugCount: 0,
      supportedUserUids: const [],
    );
    _confessions.insert(0, newConf);
    await _saveConfessionsToPrefs();
    return newConf;
  }

  @override
  Future<ConfessionModel?> sendVirtualHug(String confessionId, String senderUid) async {
    // Nạp confessions trước nếu rỗng
    if (_confessions.isEmpty) {
      await fetchConfessions();
    }
    final index = _confessions.indexWhere((c) => c.id == confessionId);
    if (index != -1) {
      final confession = _confessions[index];
      if (!confession.supportedUserUids.contains(senderUid)) {
        final updated = ConfessionModel(
          id: confession.id,
          content: confession.content,
          timestamp: confession.timestamp,
          hugCount: confession.hugCount + 1,
          supportedUserUids: [...confession.supportedUserUids, senderUid],
        );
        _confessions[index] = updated;
        await _saveConfessionsToPrefs();
        return updated;
      }
      return confession;
    }
    return null;
  }

  @override
  Future<RitualModel?> fetchTodayRitual(String uid, String date) async {
    final key = 'ritual_${uid}_$date';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      final decoded = jsonDecode(savedData);
      return RitualModel.fromMap(decoded, key);
    }
    return null;
  }

  @override
  Future<RitualModel> completeTodayRitual(
    String uid,
    String date,
    String affirmation,
    String microOfferingId,
    String intention,
  ) async {
    final key = 'ritual_${uid}_$date';
    final ritual = RitualModel(
      id: key,
      uid: uid,
      date: date,
      affirmationText: affirmation,
      microOfferingId: microOfferingId,
      intention: intention,
      completed: true,
    );
    await _prefs.setString(key, jsonEncode(ritual.toMap()));
    return ritual;
  }

  @override
  Future<UserModel> fetchSpiritualProfile(String uid) async {
    final key = 'profile_$uid';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      return UserModel.fromMap(jsonDecode(savedData));
    }
    final defaultProfile = UserModel(
      uid: uid,
      email: 'user@anam.com',
      displayName: 'Lữ Khách',
      empathyPoints: 10,
      streak: 1,
      lastRitualDate: null,
      avatarSymbol: 'Lotus',
    );
    await _prefs.setString(key, jsonEncode(defaultProfile.toMap()));
    return defaultProfile;
  }

  @override
  Future<void> updateSpiritualAvatar(String uid, String symbol) async {
    final key = 'profile_$uid';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      final profile = UserModel.fromMap(jsonDecode(savedData));
      final updated = profile.copyWith(avatarSymbol: symbol);
      await _prefs.setString(key, jsonEncode(updated.toMap()));
    }
  }
}

// TRIỂN KHAI FIRESTORE DATABASE REPOSITORY THẬT
class FirebaseDatabaseRepository extends BaseDatabaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> init() async {}

  @override
  Future<List<ConfessionModel>> fetchConfessions() async {
    try {
      final snapshot = await _firestore
          .collection('confessions')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();
      return snapshot.docs
          .map((doc) => ConfessionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Lỗi fetch confessions Repository: $e");
      rethrow;
    }
  }

  @override
  Future<ConfessionModel> addConfession(String content) async {
    try {
      final ref = _firestore.collection('confessions').doc();
      final newConf = ConfessionModel(
        id: ref.id,
        content: content,
        timestamp: DateTime.now(),
        hugCount: 0,
        supportedUserUids: const [],
      );
      await ref.set(newConf.toMap());
      return newConf;
    } catch (e) {
      debugPrint("Lỗi thêm xưng tội Repository: $e");
      rethrow;
    }
  }

  @override
  Future<ConfessionModel?> sendVirtualHug(String confessionId, String senderUid) async {
    try {
      final ref = _firestore.collection('confessions').doc(confessionId);
      ConfessionModel? updatedConfession;
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) return;
        final data = snapshot.data() as Map<String, dynamic>;
        final List<String> supportedUids = List<String>.from(data['supportedUserUids'] ?? []);
        if (!supportedUids.contains(senderUid)) {
          supportedUids.add(senderUid);
          final int newHugCount = (data['hugCount'] ?? 0) + 1;
          transaction.update(ref, {
            'supportedUserUids': supportedUids,
            'hugCount': newHugCount,
          });
          updatedConfession = ConfessionModel.fromMap({
            ...data,
            'supportedUserUids': supportedUids,
            'hugCount': newHugCount,
          }, confessionId);
        }
      });
      return updatedConfession;
    } catch (e) {
      debugPrint("Lỗi gửi cái ôm Repository: $e");
      rethrow;
    }
  }

  @override
  Future<RitualModel?> fetchTodayRitual(String uid, String date) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(date)
          .get();
      if (doc.exists && doc.data() != null) {
        return RitualModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi fetch ritual Repository: $e");
      rethrow;
    }
  }

  @override
  Future<RitualModel> completeTodayRitual(
    String uid,
    String date,
    String affirmation,
    String microOfferingId,
    String intention,
  ) async {
    try {
      final ritualRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('rituals')
          .doc(date);
      final ritual = RitualModel(
        id: date,
        uid: uid,
        date: date,
        affirmationText: affirmation,
        microOfferingId: microOfferingId,
        intention: intention,
        completed: true,
      );
      await ritualRef.set(ritual.toMap());

      // Cập nhật streak trong user profile
      final userRef = _firestore.collection('users').doc(uid);
      await _firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (userSnap.exists) {
          final userData = userSnap.data() as Map<String, dynamic>;
          final int currentStreak = userData['streak'] ?? 0;
          final String? lastDate = userData['lastRitualDate'];
          int newStreak = currentStreak;
          if (lastDate == null) {
            newStreak = 1;
          } else {
            final prevDate = DateTime.parse(lastDate);
            final currDate = DateTime.parse(date);
            final diff = currDate.difference(prevDate).inDays;
            if (diff == 1) {
              newStreak += 1;
            } else if (diff > 1) {
              newStreak = 1;
            }
          }
          transaction.update(userRef, {
            'streak': newStreak,
            'lastRitualDate': date,
          });
        }
      });
      return ritual;
    } catch (e) {
      debugPrint("Lỗi hoàn thành nghi lễ Repository: $e");
      rethrow;
    }
  }

  @override
  Future<UserModel> fetchSpiritualProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      } else {
        final newUser = UserModel(
          uid: uid,
          email: '',
          displayName: 'Lữ Khách',
          empathyPoints: 10,
          streak: 1,
          lastRitualDate: null,
          avatarSymbol: 'Lotus',
        );
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin profile Repository: $e");
      rethrow;
    }
  }

  @override
  Future<void> updateSpiritualAvatar(String uid, String symbol) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'avatarSymbol': symbol,
      });
    } catch (e) {
      debugPrint("Lỗi cập nhật avatar Repository: $e");
      rethrow;
    }
  }
}
