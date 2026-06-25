import 'package:equatable/equatable.dart';
import '../../daily_anchor/data/models/anchor_model.dart';

abstract class SleepSeedState extends Equatable {
  const SleepSeedState();

  @override
  List<Object?> get props => [];
}

class SleepSeedInitial extends SleepSeedState {}

class SleepSeedLoading extends SleepSeedState {}

class SleepSeedStatusLoaded extends SleepSeedState {
  final AnchorModel? yesterdayAnchor;
  final bool canSprout; // Đã gieo đêm qua và sáng nay thức dậy đủ điều kiện nhận mầm

  const SleepSeedStatusLoaded({
    required this.yesterdayAnchor,
    required this.canSprout,
  });

  @override
  List<Object?> get props => [yesterdayAnchor, canSprout];
}

class SleepSeedSownSuccess extends SleepSeedState {
  final AnchorModel anchor;

  const SleepSeedSownSuccess(this.anchor);

  @override
  List<Object?> get props => [anchor];
}

class SleepSeedCollectionSuccess extends SleepSeedState {
  final AnchorModel anchor;

  const SleepSeedCollectionSuccess(this.anchor);

  @override
  List<Object?> get props => [anchor];
}

class SleepSeedFailure extends SleepSeedState {
  final String error;

  const SleepSeedFailure(this.error);

  @override
  List<Object?> get props => [error];
}
