import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/release_space/data/models/release_model.dart';
import '../../features/daily_anchor/data/models/anchor_model.dart';
import '../../features/auth/data/models/user_model.dart';

abstract class BaseDatabaseRepository {
  String? currentMindState;
  
  Future<void> init();
  Future<List<ReleaseModel>> fetchReleases();
  Future<ReleaseModel> addRelease(String content);
  Future<ReleaseModel?> sendVirtualHug(String releaseId, String senderUid);
  Future<AnchorModel?> fetchTodayAnchor(String uid, String date);
  Future<AnchorModel?> fetchYesterdayAnchor(String uid, String yesterdayDate);
  // Morning ritual: Intention → Offering → Affirmation
  Future<AnchorModel> completeMorningAnchor(String uid, String date, String affirmation, String microOfferingId, String intention);
  // Alias backward compat cho code cũ
  Future<AnchorModel> completeTodayAnchor(String uid, String date, String affirmation, String microOfferingId, String intention, {String? emotionCheckIn});
  // Evening ritual: Check-in → Review intention → Journal note
  Future<AnchorModel> completeEveningReflection(String uid, String date, String emotion, String note, bool intentionAchieved);
  Future<void> markIntentionReviewed(String uid, String date, bool achieved);
  Future<UserModel> fetchSpiritualProfile(String uid);
  Future<void> updateSpiritualAvatar(String uid, String symbol);
  Future<void> saveReflection(String prompt, String content);
  Future<List<Map<String, dynamic>>> fetchReflections();
}

// TRIỂN KHAI MOCK DATABASE REPOSITORY (Lưu SharedPreferences offline)
class MockDatabaseRepository extends BaseDatabaseRepository {
  List<ReleaseModel> _releases = [];
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<ReleaseModel>> fetchReleases() async {
    final rawList = _prefs.getStringList('mock_releases') ?? [];
    if (rawList.isEmpty) {
      _releases = [
        ReleaseModel(
          id: 'c1',
          content: "Tôi thấy áp lực kinh khủng từ kỳ vọng của bố mẹ. Nhiều lúc chỉ muốn biến mất...",
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          hugCount: 12,
          supportedUserUids: const ['user_x'],
        ),
        ReleaseModel(
          id: 'c2',
          content: "Đã 3 tháng thất nghiệp rồi. Cảm thấy bản thân thật vô dụng, không bằng bạn bè cùng trang lứa.",
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          hugCount: 24,
          supportedUserUids: const [],
        ),
        ReleaseModel(
          id: 'c3',
          content: "Hôm nay làm vỡ cái cốc của đồng nghiệp nhưng không dám nhận. Thấy tội lỗi và hèn nhát quá.",
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          hugCount: 5,
          supportedUserUids: const [],
        ),
      ];
      await _saveReleasesToPrefs();
    } else {
      _releases = rawList.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return ReleaseModel(
          id: decoded['id'],
          content: decoded['content'],
          timestamp: DateTime.parse(decoded['timestamp']),
          hugCount: decoded['hugCount'],
          supportedUserUids: List<String>.from(decoded['supportedUserUids'] ?? []),
          isBurned: decoded['isBurned'] ?? false,
        );
      }).toList();
      _releases.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return _releases;
  }

  Future<void> _saveReleasesToPrefs() async {
    final listToSave = _releases.map((c) => jsonEncode({
      'id': c.id,
      'content': c.content,
      'timestamp': c.timestamp.toIso8601String(),
      'hugCount': c.hugCount,
      'supportedUserUids': c.supportedUserUids,
      'isBurned': c.isBurned,
    })).toList();
    await _prefs.setStringList('mock_releases', listToSave);
  }

  @override
  Future<ReleaseModel> addRelease(String content) async {
    final newRelease = ReleaseModel(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      timestamp: DateTime.now(),
      hugCount: 0,
      supportedUserUids: const [],
    );
    _releases.insert(0, newRelease);
    await _saveReleasesToPrefs();
    return newRelease;
  }

  @override
  Future<ReleaseModel?> sendVirtualHug(String releaseId, String senderUid) async {
    if (_releases.isEmpty) {
      await fetchReleases();
    }
    final index = _releases.indexWhere((c) => c.id == releaseId);
    if (index != -1) {
      final release = _releases[index];
      if (!release.supportedUserUids.contains(senderUid)) {
        final updated = ReleaseModel(
          id: release.id,
          content: release.content,
          timestamp: release.timestamp,
          hugCount: release.hugCount + 1,
          supportedUserUids: [...release.supportedUserUids, senderUid],
        );
        _releases[index] = updated;
        await _saveReleasesToPrefs();
        return updated;
      }
      return release;
    }
    return null;
  }

  @override
  Future<AnchorModel?> fetchTodayAnchor(String uid, String date) async {
    final key = 'anchor_${uid}_$date';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      final decoded = jsonDecode(savedData);
      return AnchorModel.fromMap(decoded, key);
    }
    return null;
  }

  @override
  Future<AnchorModel?> fetchYesterdayAnchor(String uid, String yesterdayDate) async {
    final key = 'anchor_${uid}_$yesterdayDate';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      final decoded = jsonDecode(savedData);
      return AnchorModel.fromMap(decoded, key);
    }
    return null;
  }

  @override
  Future<void> markIntentionReviewed(String uid, String date, bool achieved) async {
    final key = 'anchor_${uid}_$date';
    final savedData = _prefs.getString(key);
    if (savedData != null) {
      final decoded = jsonDecode(savedData) as Map<String, dynamic>;
      decoded['intentionReviewed'] = achieved;
      await _prefs.setString(key, jsonEncode(decoded));
    }
  }

  @override
  Future<AnchorModel> completeMorningAnchor(
    String uid,
    String date,
    String affirmation,
    String microOfferingId,
    String intention,
  ) async {
    final key = 'anchor_\${uid}_\$date';
    final anchor = AnchorModel(
      id: key, uid: uid, date: date,
      affirmationText: affirmation,
      microOfferingId: microOfferingId,
      intention: intention,
      morningCompleted: true,
    );
    await _prefs.setString(key, jsonEncode(anchor.toMap()));
    return anchor;
  }

  @override
  Future<AnchorModel> completeEveningReflection(
    String uid, String date, String emotion, String note, bool intentionAchieved,
  ) async {
    final key = 'anchor_\${uid}_\$date';
    final savedData = _prefs.getString(key);
    final Map<String, dynamic> base = savedData != null
        ? jsonDecode(savedData) as Map<String, dynamic>
        : {'uid': uid, 'date': date, 'affirmationText': '', 'microOfferingId': '', 'intention': ''};
    base['eveningCompleted'] = true;
    base['eveningEmotion'] = emotion;
    base['eveningNote'] = note;
    base['intentionReviewed'] = intentionAchieved;
    await _prefs.setString(key, jsonEncode(base));
    return AnchorModel.fromMap(base, key);
  }

  @override
  Future<AnchorModel> completeTodayAnchor(
    String uid,
    String date,
    String affirmation,
    String microOfferingId,
    String intention, {
    String? emotionCheckIn,
  }) async {
    final key = 'anchor_${uid}_$date';
    final anchor = AnchorModel(
      id: key,
      uid: uid,
      date: date,
      affirmationText: affirmation,
      microOfferingId: microOfferingId,
      intention: intention,
      morningCompleted: true,
      emotionCheckIn: emotionCheckIn,
    );
    await _prefs.setString(key, jsonEncode(anchor.toMap()));
    return anchor;
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

  @override
  Future<void> saveReflection(String prompt, String content) async {
    final list = _prefs.getStringList('local_reflections') ?? [];
    final item = jsonEncode({
      'prompt': prompt,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
    list.add(item);
    await _prefs.setStringList('local_reflections', list);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReflections() async {
    final rawList = _prefs.getStringList('local_reflections') ?? [];
    return rawList.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList().reversed.toList();
  }
}

// TRIỂN KHAI FIRESTORE DATABASE REPOSITORY THẬT
class FirebaseDatabaseRepository extends BaseDatabaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<ReleaseModel>> fetchReleases() async {
    try {
      final snapshot = await _firestore
          .collection('releases')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get();
      return snapshot.docs
          .map((doc) => ReleaseModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Lỗi fetch releases Repository: $e");
      rethrow;
    }
  }

  @override
  Future<ReleaseModel> addRelease(String content) async {
    try {
      final ref = _firestore.collection('releases').doc();
      final newRelease = ReleaseModel(
        id: ref.id,
        content: content,
        timestamp: DateTime.now(),
        hugCount: 0,
        supportedUserUids: const [],
      );
      await ref.set(newRelease.toMap());
      return newRelease;
    } catch (e) {
      debugPrint("Lỗi thêm giải phóng Repository: $e");
      rethrow;
    }
  }

  @override
  Future<ReleaseModel?> sendVirtualHug(String releaseId, String senderUid) async {
    try {
      final ref = _firestore.collection('releases').doc(releaseId);
      ReleaseModel? updatedRelease;
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
          updatedRelease = ReleaseModel.fromMap({
            ...data,
            'supportedUserUids': supportedUids,
            'hugCount': newHugCount,
          }, releaseId);
        }
      });
      return updatedRelease;
    } catch (e) {
      debugPrint("Lỗi gửi cái ôm Repository: $e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel?> fetchTodayAnchor(String uid, String date) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('anchors')
          .doc(date)
          .get();
      if (doc.exists && doc.data() != null) {
        return AnchorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Lỗi fetch anchor Repository: $e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel?> fetchYesterdayAnchor(String uid, String yesterdayDate) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('anchors')
          .doc(yesterdayDate)
          .get();
      if (doc.exists && doc.data() != null) {
        return AnchorModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Loi fetch yesterday anchor: $e");
      return null;
    }
  }

  @override
  Future<void> markIntentionReviewed(String uid, String date, bool achieved) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('anchors')
          .doc(date)
          .update({'intentionReviewed': achieved});
    } catch (e) {
      debugPrint("Loi cap nhat intentionReviewed: $e");
    }
  }

  @override
  Future<AnchorModel> completeMorningAnchor(
    String uid, String date, String affirmation, String microOfferingId, String intention,
  ) async {
    try {
      final ref = _firestore.collection('users').doc(uid).collection('anchors').doc(date);
      final anchor = AnchorModel(
        id: date, uid: uid, date: date,
        affirmationText: affirmation,
        microOfferingId: microOfferingId,
        intention: intention,
        morningCompleted: true,
      );
      await ref.set(anchor.toMap(), SetOptions(merge: true));
      return anchor;
    } catch (e) {
      debugPrint("Loi completeMorningAnchor: \$e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel> completeEveningReflection(
    String uid, String date, String emotion, String note, bool intentionAchieved,
  ) async {
    try {
      final ref = _firestore.collection('users').doc(uid).collection('anchors').doc(date);
      await ref.set({
        'eveningCompleted': true,
        'eveningEmotion': emotion,
        'eveningNote': note,
        'intentionReviewed': intentionAchieved,
      }, SetOptions(merge: true));
      final snap = await ref.get();
      return AnchorModel.fromMap(snap.data()!, date);
    } catch (e) {
      debugPrint("Loi completeEveningReflection: \$e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel> completeTodayAnchor(
    String uid,
    String date,
    String affirmation,
    String microOfferingId,
    String intention, {
    String? emotionCheckIn,
  }) async {
    try {
      final anchorRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('anchors')
          .doc(date);
      final anchor = AnchorModel(
        id: date,
        uid: uid,
        date: date,
        affirmationText: affirmation,
        microOfferingId: microOfferingId,
        intention: intention,
        morningCompleted: true,
        emotionCheckIn: emotionCheckIn,
      );
      await anchorRef.set(anchor.toMap());

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
      return anchor;
    } catch (e) {
      debugPrint("Lỗi hoàn thành điểm neo Repository: $e");
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

  @override
  Future<void> saveReflection(String prompt, String content) async {
    final list = _prefs.getStringList('local_reflections') ?? [];
    final item = jsonEncode({
      'prompt': prompt,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
    list.add(item);
    await _prefs.setStringList('local_reflections', list);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchReflections() async {
    final rawList = _prefs.getStringList('local_reflections') ?? [];
    return rawList.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList().reversed.toList();
  }
}
