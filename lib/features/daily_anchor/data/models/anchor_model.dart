class AnchorModel {
  final String id;
  final String uid;
  final String date; // YYYY-MM-DD
  final String affirmationText;
  final String microOfferingId;
  final String intention;
  final bool completed;
  // Trạng thái cảm xúc được ghi nhận từ bước Check-In.
  // Nullable để đảm bảo tương thích ngược với các anchor records cũ.
  final String? emotionCheckIn;

  AnchorModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.affirmationText,
    required this.microOfferingId,
    required this.intention,
    this.completed = false,
    this.emotionCheckIn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': date,
      'affirmationText': affirmationText,
      'microOfferingId': microOfferingId,
      'intention': intention,
      'completed': completed,
      'emotionCheckIn': emotionCheckIn,
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
      completed: map['completed'] ?? false,
      emotionCheckIn: map['emotionCheckIn'], // nullable — records cũ trả về null
    );
  }
}
