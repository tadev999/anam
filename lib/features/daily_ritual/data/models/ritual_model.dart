class RitualModel {
  final String id;
  final String uid;
  final String date; // YYYY-MM-DD
  final String affirmationText;
  final String microOfferingId;
  final String intention;
  final bool completed;

  RitualModel({
    required this.id,
    required this.uid,
    required this.date,
    required this.affirmationText,
    required this.microOfferingId,
    required this.intention,
    this.completed = false,
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
    };
  }

  factory RitualModel.fromMap(Map<String, dynamic> map, String docId) {
    return RitualModel(
      id: docId,
      uid: map['uid'] ?? '',
      date: map['date'] ?? '',
      affirmationText: map['affirmationText'] ?? '',
      microOfferingId: map['microOfferingId'] ?? '',
      intention: map['intention'] ?? '',
      completed: map['completed'] ?? false,
    );
  }
}
