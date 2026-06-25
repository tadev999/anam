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
  Future<List<AnchorModel>> fetchMonthAnchors(String uid, String yearMonth);
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
  // Sleep Seed
  Future<AnchorModel> sowSleepSeed(String uid, String date, String sownAt);
  Future<AnchorModel> collectSleepSprout(String uid, String date, String sproutedAt);
}

// TRIỂN KHAI MOCK DATABASE REPOSITORY (Lưu SharedPreferences offline)
class MockDatabaseRepository extends BaseDatabaseRepository {
  List<ReleaseModel> _releases = [];
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await seedJune2026MockDataForUid('mock_user_123');
  }

  Future<void> seedJune2026MockDataForUid(String uid) async {
    final isSeeded = _prefs.getBool('seeded_june_2026_sleep_$uid') ?? false;
    if (isSeeded) return;

    final List<Map<String, dynamic>> mockAnchors = [
      // Day 1: grateful
      {
        'date': '2026-06-01',
        'affirmationText': 'Tôi bình yên và trọn vẹn trong hiện tại',
        'microOfferingId': 'offering_1',
        'intention': 'Dành 15 phút thiền định buổi sáng',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'grateful',
        'eveningNote': 'Cảm nhận rõ rệt hơi thở và nhịp tim khi thiền',
        'intentionReviewed': true,
      },
      // Day 2: peaceful
      {
        'date': '2026-06-02',
        'affirmationText': 'Mỗi giây phút đều là một món quà',
        'microOfferingId': 'offering_2',
        'intention': 'Uống trà định tâm không điện thoại',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Vị trà oải hương thật thanh tịnh',
        'intentionReviewed': true,
        'sleepSeedSownAt': '2026-06-02T22:45:00',
        'sleepSeedSproutedAt': '2026-06-03T06:30:00',
        'sleepSeedCollected': true,
      },
      // Day 3: morning completed only
      {
        'date': '2026-06-03',
        'affirmationText': 'Bước chân tôi chạm vào lòng đất mẹ',
        'microOfferingId': 'offering_3',
        'intention': 'Đi bộ công viên',
        'morningCompleted': true,
        'eveningCompleted': false,
      },
      // Day 4: lonely
      {
        'date': '2026-06-04',
        'affirmationText': 'Tôi kết nối sâu sắc với mọi người xung quanh',
        'microOfferingId': 'offering_4',
        'intention': 'Gọi điện hỏi thăm người bạn cũ',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'lonely',
        'eveningNote': 'Bạn bận không nghe máy, cảm giác hơi lạc lõng nhưng ổn',
        'intentionReviewed': false,
      },
      // Day 5: peaceful
      {
        'date': '2026-06-05',
        'affirmationText': 'Tâm trí tôi trong lành như buổi sớm mai',
        'microOfferingId': 'offering_5',
        'intention': 'Viết nhật ký lòng biết ơn',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Buổi chiều ngồi ngắm mưa rơi rất bình lặng',
        'intentionReviewed': true,
        'sleepSeedSownAt': '2026-06-05T23:10:00',
        'sleepSeedSproutedAt': '2026-06-06T07:05:00',
        'sleepSeedCollected': true,
      },
      // Day 6: lonely
      {
        'date': '2026-06-06',
        'affirmationText': 'Tôi là người bạn tốt nhất của chính mình',
        'microOfferingId': 'offering_6',
        'intention': 'Đọc 10 trang sách tâm lý học',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'lonely',
        'eveningNote': 'Căn phòng tối nay yên ắng quá mức bình thường',
        'intentionReviewed': true,
      },
      // Day 8: peaceful
      {
        'date': '2026-06-08',
        'affirmationText': 'Tôi nuôi dưỡng sự sống xung quanh và bên trong',
        'microOfferingId': 'offering_8',
        'intention': 'Tưới cây ngoài ban công',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Mầm cây nhỏ đã hé nở lá xanh đầu tiên',
        'intentionReviewed': true,
        'sleepSeedSownAt': '2026-06-08T22:30:00',
        'sleepSeedSproutedAt': '2026-06-09T06:15:00',
        'sleepSeedCollected': true,
      },
      // Day 9: overthinking
      {
        'date': '2026-06-09',
        'affirmationText': 'Tôi tin tưởng vào tiến trình của mình',
        'microOfferingId': 'offering_9',
        'intention': 'Hoàn thành báo cáo công việc sớm',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'overthinking',
        'eveningNote': 'Đầu óc cứ lẩn quẩn lo lắng về deadline tuần tới',
        'intentionReviewed': true,
      },
      // Day 10: burnout
      {
        'date': '2026-06-10',
        'affirmationText': 'Tôi cho phép bản thân nghỉ ngơi khi mệt mỏi',
        'microOfferingId': 'offering_10',
        'intention': 'Làm việc tập trung tối đa',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'burnout',
        'eveningNote': 'Một ngày kiệt sức vì họp hành liên tục, đầu muốn nổ tung',
        'intentionReviewed': false,
      },
      // Day 11: overthinking
      {
        'date': '2026-06-11',
        'affirmationText': 'Tôi buông bỏ những điều nằm ngoài tầm kiểm soát',
        'microOfferingId': 'offering_11',
        'intention': 'Lập kế hoạch tuần mới rõ ràng',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'overthinking',
        'eveningNote': 'Lại mất ngủ vì suy nghĩ quá nhiều kịch bản rủi ro',
        'intentionReviewed': false,
      },
      // Day 12: grateful
      {
        'date': '2026-06-12',
        'affirmationText': 'Mọi nỗ lực của tôi đều đáng trân quý',
        'microOfferingId': 'offering_12',
        'intention': 'Nấu một bữa ăn ấm cúng',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'grateful',
        'eveningNote': 'Mẹ gọi điện khen món canh sườn hạt sen nấu ngon',
        'intentionReviewed': true,
        'sleepSeedSownAt': '2026-06-12T23:55:00',
        'sleepSeedSproutedAt': '2026-06-13T08:00:00',
        'sleepSeedCollected': true,
      },
      // Day 13: lonely
      {
        'date': '2026-06-13',
        'affirmationText': 'Sự cô độc là khoảng trống để thấu hiểu bản thân',
        'microOfferingId': 'offering_13',
        'intention': 'Ăn tối một mình không lướt mạng',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'lonely',
        'eveningNote': 'Nhìn bàn ăn một người, chợt nhớ những ngày xưa cũ',
        'intentionReviewed': true,
      },
      // Day 14: overthinking
      {
        'date': '2026-06-14',
        'affirmationText': 'Tâm trí tôi trật tự và thông suốt',
        'microOfferingId': 'offering_14',
        'intention': 'Dọn dẹp phòng ngủ sạch sẽ',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'overthinking',
        'eveningNote': 'Vừa dọn dẹp vừa nghĩ vẩn vơ về định hướng tương lai 5 năm tới',
        'intentionReviewed': true,
      },
      // Day 16: peaceful
      {
        'date': '2026-06-16',
        'affirmationText': 'Giấc ngủ là cái ôm dịu êm của vũ trụ',
        'microOfferingId': 'offering_16',
        'intention': 'Tắt thiết bị điện tử từ 9h tối',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Ngủ rất ngon và sâu, thức dậy sảng khoái',
        'intentionReviewed': true,
      },
      // Day 17: burnout
      {
        'date': '2026-06-17',
        'affirmationText': 'Tôi đón nhận mọi thử thách bằng sự điềm tĩnh',
        'microOfferingId': 'offering_17',
        'intention': 'Giải quyết xung đột với đồng nghiệp',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'burnout',
        'eveningNote': 'Căng thẳng tột độ sau cuộc tranh luận gay gắt',
        'intentionReviewed': false,
      },
      // Day 18: grateful
      {
        'date': '2026-06-18',
        'affirmationText': 'Biết ơn vì được dẫn dắt và chỉ bảo tận tình',
        'microOfferingId': 'offering_18',
        'intention': 'Gửi tin nhắn cảm ơn sếp',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'grateful',
        'eveningNote': 'Nhận được phản hồi khích lệ rất ấm lòng từ team',
        'intentionReviewed': true,
      },
      // Day 19: morning completed only
      {
        'date': '2026-06-19',
        'affirmationText': 'Tôi thanh lọc cơ thể và tâm hồn',
        'microOfferingId': 'offering_19',
        'intention': 'Uống đủ 2 lít nước',
        'morningCompleted': true,
        'eveningCompleted': false,
      },
      // Day 20: peaceful
      {
        'date': '2026-06-20',
        'affirmationText': 'Tần số của tôi hòa nhịp cùng sự hài hòa của tự nhiên',
        'microOfferingId': 'offering_20',
        'intention': 'Nghe nhạc thiền tần số 432Hz',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Âm thanh tiếng chuông xoay Tây Tạng giúp tinh thần dịu lại',
        'intentionReviewed': true,
        'sleepSeedSownAt': '2026-06-20T22:15:00',
        'sleepSeedSproutedAt': '2026-06-21T06:00:00',
        'sleepSeedCollected': true,
      },
      // Day 21: overthinking
      {
        'date': '2026-06-21',
        'affirmationText': 'Tôi nói bằng sự tự tin và chân thành của mình',
        'microOfferingId': 'offering_21',
        'intention': 'Chuẩn bị bài thuyết trình slide',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'overthinking',
        'eveningNote': 'Lo sợ mọi người phán xét cách mình trình bày',
        'intentionReviewed': false,
      },
      // Day 22: lonely
      {
        'date': '2026-06-22',
        'affirmationText': 'Tôi thuộc về thế giới rộng lớn này',
        'microOfferingId': 'offering_22',
        'intention': 'Đi dạo hồ Tây lúc hoàng hôn',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'lonely',
        'eveningNote': 'Gió hồ mát lạnh, xung quanh ai cũng có đôi, cảm thấy cô đơn nhưng dễ chịu',
        'intentionReviewed': true,
      },
      // Day 23: grateful
      {
        'date': '2026-06-23',
        'affirmationText': 'Tôi luôn hướng về phía ánh sáng mặt trời',
        'microOfferingId': 'offering_23',
        'intention': 'Mua tặng bản thân một bông hoa hướng dương',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'grateful',
        'eveningNote': 'Màu vàng rực của hoa làm bừng sáng góc làm việc',
        'intentionReviewed': true,
      },
      // Day 24: peaceful
      {
        'date': '2026-06-24',
        'affirmationText': 'Tình yêu thương lan tỏa từ tôi đến muôn nơi',
        'microOfferingId': 'offering_24',
        'intention': 'Chia sẻ niềm vui với người thân',
        'morningCompleted': true,
        'eveningCompleted': true,
        'eveningEmotion': 'peaceful',
        'eveningNote': 'Cuộc trò chuyện ngắn với mẹ ngập tràn tiếng cười',
        'intentionReviewed': true,
      },
    ];

    for (final data in mockAnchors) {
      final date = data['date'] as String;
      final key = 'anchor_${uid}_$date';
      final anchorMap = {
        'id': key,
        'uid': uid,
        ...data,
      };
      await _prefs.setString(key, jsonEncode(anchorMap));
    }

    await _prefs.setBool('seeded_june_2026_sleep_$uid', true);
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
  Future<List<AnchorModel>> fetchMonthAnchors(String uid, String yearMonth) async {
    if (yearMonth == '2026-06') {
      await seedJune2026MockDataForUid(uid);
    }
    final keys = _prefs.getKeys();
    final prefix = 'anchor_${uid}_${yearMonth}-';
    final List<AnchorModel> list = [];
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final savedData = _prefs.getString(key);
        if (savedData != null) {
          list.add(AnchorModel.fromMap(jsonDecode(savedData), key));
        }
      }
    }
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
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
    final key = 'anchor_${uid}_$date';
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
    final key = 'anchor_${uid}_$date';
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
  Future<AnchorModel> sowSleepSeed(String uid, String date, String sownAt) async {
    final key = 'anchor_${uid}_$date';
    final savedData = _prefs.getString(key);
    final Map<String, dynamic> base = savedData != null
        ? jsonDecode(savedData) as Map<String, dynamic>
        : {'uid': uid, 'date': date, 'affirmationText': '', 'microOfferingId': '', 'intention': ''};
    base['sleepSeedSownAt'] = sownAt;
    base['sleepSeedCollected'] = false;
    await _prefs.setString(key, jsonEncode(base));
    return AnchorModel.fromMap(base, key);
  }

  @override
  Future<AnchorModel> collectSleepSprout(String uid, String date, String sproutedAt) async {
    final key = 'anchor_${uid}_$date';
    final savedData = _prefs.getString(key);
    final Map<String, dynamic> base = savedData != null
        ? jsonDecode(savedData) as Map<String, dynamic>
        : {'uid': uid, 'date': date, 'affirmationText': '', 'microOfferingId': '', 'intention': ''};
    base['sleepSeedCollected'] = true;
    base['sleepSeedSproutedAt'] = sproutedAt;
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
  Future<List<AnchorModel>> fetchMonthAnchors(String uid, String yearMonth) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('anchors')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$yearMonth-01')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$yearMonth-31')
          .get();
      final list = snapshot.docs
          .map((doc) => AnchorModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    } catch (e) {
      debugPrint("Loi fetch month anchors: $e");
      rethrow;
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
      debugPrint("Loi completeEveningReflection: $e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel> sowSleepSeed(String uid, String date, String sownAt) async {
    try {
      final ref = _firestore.collection('users').doc(uid).collection('anchors').doc(date);
      await ref.set({
        'sleepSeedSownAt': sownAt,
        'sleepSeedCollected': false,
      }, SetOptions(merge: true));
      final snap = await ref.get();
      return AnchorModel.fromMap(snap.data()!, date);
    } catch (e) {
      debugPrint("Loi sowSleepSeed: $e");
      rethrow;
    }
  }

  @override
  Future<AnchorModel> collectSleepSprout(String uid, String date, String sproutedAt) async {
    try {
      final ref = _firestore.collection('users').doc(uid).collection('anchors').doc(date);
      await ref.set({
        'sleepSeedCollected': true,
        'sleepSeedSproutedAt': sproutedAt,
      }, SetOptions(merge: true));
      final snap = await ref.get();
      return AnchorModel.fromMap(snap.data()!, date);
    } catch (e) {
      debugPrint("Loi collectSleepSprout: $e");
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
      debugPrint("Lỗi hoàn thành ý niệm ngày mới Repository: $e");
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
