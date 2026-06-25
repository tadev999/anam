class AnchorModel {
  final String id;
  final String uid;
  final String date; // YYYY-MM-DD

  // --- Morning Anchor fields ---
  final String affirmationText;
  final String microOfferingId;
  final String intention;
  // morningCompleted thay thế semantics của 'completed' cũ
  final bool morningCompleted;

  // --- Evening Reflection fields (mới) ---
  final bool eveningCompleted;
  final String? eveningEmotion; // cảm xúc check-in buổi tối
  final String? eveningNote;    // ghi chú 1 điều học được hôm nay

  // --- Sleep Seed fields (mới) ---
  final String? sleepSeedSownAt;     // Thời điểm gieo hạt ngủ ngon (ISO-8601)
  final String? sleepSeedSproutedAt; // Thời điểm thu hoạch mầm non (ISO-8601)
  final bool sleepSeedCollected;     // Đã thu hoạch mầm non chưa

  // --- Backward compat fields ---
  // emotionCheckIn: dữ liệu cũ trước khi tách morning/evening
  final String? emotionCheckIn;
  // intentionReviewed: người dùng đã review lại intention hôm qua
  // null = chưa được hỏi, true = đã làm, false = chưa làm
  final bool? intentionReviewed;

  // Getter backward compat — code cũ vẫn dùng được
  bool get completed => morningCompleted;

  AnchorModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.affirmationText,
    required this.microOfferingId,
    required this.intention,
    this.morningCompleted = false,
    this.eveningCompleted = false,
    this.eveningEmotion,
    this.eveningNote,
    this.sleepSeedSownAt,
    this.sleepSeedSproutedAt,
    this.sleepSeedCollected = false,
    this.emotionCheckIn,
    this.intentionReviewed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': date,
      'affirmationText': affirmationText,
      'microOfferingId': microOfferingId,
      'intention': intention,
      'morningCompleted': morningCompleted,
      'completed': morningCompleted, // backward compat cho Firestore records cũ
      'eveningCompleted': eveningCompleted,
      'eveningEmotion': eveningEmotion,
      'eveningNote': eveningNote,
      'sleepSeedSownAt': sleepSeedSownAt,
      'sleepSeedSproutedAt': sleepSeedSproutedAt,
      'sleepSeedCollected': sleepSeedCollected,
      'emotionCheckIn': emotionCheckIn,
      'intentionReviewed': intentionReviewed,
    };
  }

  factory AnchorModel.fromMap(Map<String, dynamic> map, String docId) {
    return AnchorModel(
      id: docId,
      uid: map['uid'] ?? '',
      date: map['date'] ?? '',
      affirmationText: map['affirmationText'] ?? '',
      microOfferingId: map['microOfferingId'] ?? '',
      intention: map['intention'] ?? '',
      // Đọc morningCompleted, fallback về 'completed' cũ
      morningCompleted: map['morningCompleted'] ?? map['completed'] ?? false,
      eveningCompleted: map['eveningCompleted'] ?? false,
      eveningEmotion: map['eveningEmotion'],
      eveningNote: map['eveningNote'],
      sleepSeedSownAt: map['sleepSeedSownAt'],
      sleepSeedSproutedAt: map['sleepSeedSproutedAt'],
      sleepSeedCollected: map['sleepSeedCollected'] ?? false,
      emotionCheckIn: map['emotionCheckIn'],
      intentionReviewed: map['intentionReviewed'],
    );
  }
}
