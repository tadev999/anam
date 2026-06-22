class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int empathyPoints;
  final int streak;
  final String? lastRitualDate; // Định dạng YYYY-MM-DD
  final String avatarSymbol; // Lotus, Hearth, River...

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.empathyPoints = 0,
    this.streak = 0,
    this.lastRitualDate,
    this.avatarSymbol = 'Lotus',
  });

  String get spiritualRole {
    if (empathyPoints >= 50) {
      return "Keeper (Người gìn giữ)";
    }
    return "Seeker (Người tìm kiếm)";
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'empathyPoints': empathyPoints,
      'streak': streak,
      'lastRitualDate': lastRitualDate,
      'avatarSymbol': avatarSymbol,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Ẩn danh',
      empathyPoints: map['empathyPoints'] ?? 0,
      streak: map['streak'] ?? 0,
      lastRitualDate: map['lastRitualDate'],
      avatarSymbol: map['avatarSymbol'] ?? 'Lotus',
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? empathyPoints,
    int? streak,
    String? lastRitualDate,
    String? avatarSymbol,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      empathyPoints: empathyPoints ?? this.empathyPoints,
      streak: streak ?? this.streak,
      lastRitualDate: lastRitualDate ?? this.lastRitualDate,
      avatarSymbol: avatarSymbol ?? this.avatarSymbol,
    );
  }
}
