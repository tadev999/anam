import 'package:cloud_firestore/cloud_firestore.dart';

class ConfessionModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final int hugCount;
  final List<String> supportedUserUids;
  final bool isBurned;

  ConfessionModel({
    required this.id,
    required this.content,
    required this.timestamp,
    this.hugCount = 0,
    this.supportedUserUids = const [],
    this.isBurned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'hugCount': hugCount,
      'supportedUserUids': supportedUserUids,
      'isBurned': isBurned,
    };
  }

  factory ConfessionModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedTime;
    var rawTime = map['timestamp'];
    if (rawTime is Timestamp) {
      parsedTime = rawTime.toDate();
    } else if (rawTime is String) {
      parsedTime = DateTime.parse(rawTime);
    } else {
      parsedTime = DateTime.now();
    }

    return ConfessionModel(
      id: docId,
      content: map['content'] ?? '',
      timestamp: parsedTime,
      hugCount: map['hugCount'] ?? 0,
      supportedUserUids: List<String>.from(map['supportedUserUids'] ?? []),
      isBurned: map['isBurned'] ?? false,
    );
  }
}
