import 'package:equatable/equatable.dart';

abstract class SleepSeedEvent extends Equatable {
  const SleepSeedEvent();

  @override
  List<Object?> get props => [];
}

class CheckSleepSeedStatusRequested extends SleepSeedEvent {
  final String uid;
  final String date; // Hôm nay (YYYY-MM-DD)

  const CheckSleepSeedStatusRequested(this.uid, this.date);

  @override
  List<Object?> get props => [uid, date];
}

class SowSleepSeedRequested extends SleepSeedEvent {
  final String uid;
  final String date; // Hôm nay (ngày gieo)
  final DateTime sownAt;

  const SowSleepSeedRequested({
    required this.uid,
    required this.date,
    required this.sownAt,
  });

  @override
  List<Object?> get props => [uid, date, sownAt];
}

class CollectSleepSproutRequested extends SleepSeedEvent {
  final String uid;
  final String date; // Ngày gieo hạt ngủ ngon (ngày hôm qua)
  final DateTime sproutedAt;

  const CollectSleepSproutRequested({
    required this.uid,
    required this.date,
    required this.sproutedAt,
  });

  @override
  List<Object?> get props => [uid, date, sproutedAt];
}
