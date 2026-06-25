import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import 'sleep_seed_event.dart';
import 'sleep_seed_state.dart';

class SleepSeedBloc extends Bloc<SleepSeedEvent, SleepSeedState> {
  final BaseDatabaseRepository _databaseRepository;

  SleepSeedBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(SleepSeedInitial()) {
    on<CheckSleepSeedStatusRequested>(_onCheckSleepSeedStatusRequested);
    on<SowSleepSeedRequested>(_onSowSleepSeedRequested);
    on<CollectSleepSproutRequested>(_onCollectSleepSproutRequested);
  }

  Future<void> _onCheckSleepSeedStatusRequested(
    CheckSleepSeedStatusRequested event,
    Emitter<SleepSeedState> emit,
  ) async {
    emit(SleepSeedLoading());
    try {
      final yesterdayDate = _getYesterdayDateString(event.date);
      final yesterdayAnchor = await _databaseRepository.fetchTodayAnchor(event.uid, yesterdayDate);

      bool canSprout = false;
      if (yesterdayAnchor != null &&
          yesterdayAnchor.sleepSeedSownAt != null &&
          !yesterdayAnchor.sleepSeedCollected) {
        final now = DateTime.now();
        final sownTime = DateTime.parse(yesterdayAnchor.sleepSeedSownAt!);
        final diff = now.difference(sownTime);

        // Nảy mầm khi qua 5 giờ sáng hôm sau và ngủ ít nhất 5 tiếng
        canSprout = now.hour >= 5 && diff.inHours >= 5;
      }

      emit(SleepSeedStatusLoaded(
        yesterdayAnchor: yesterdayAnchor,
        canSprout: canSprout,
      ));
    } catch (e) {
      emit(SleepSeedFailure(e.toString()));
    }
  }

  Future<void> _onSowSleepSeedRequested(
    SowSleepSeedRequested event,
    Emitter<SleepSeedState> emit,
  ) async {
    emit(SleepSeedLoading());
    try {
      final sownAtStr = event.sownAt.toIso8601String();
      final anchor = await _databaseRepository.sowSleepSeed(event.uid, event.date, sownAtStr);
      emit(SleepSeedSownSuccess(anchor));
    } catch (e) {
      emit(SleepSeedFailure(e.toString()));
    }
  }

  Future<void> _onCollectSleepSproutRequested(
    CollectSleepSproutRequested event,
    Emitter<SleepSeedState> emit,
  ) async {
    emit(SleepSeedLoading());
    try {
      final sproutedAtStr = event.sproutedAt.toIso8601String();
      final anchor = await _databaseRepository.collectSleepSprout(event.uid, event.date, sproutedAtStr);
      emit(SleepSeedCollectionSuccess(anchor));
    } catch (e) {
      emit(SleepSeedFailure(e.toString()));
    }
  }

  String _getYesterdayDateString(String dateStr) {
    final parsed = DateTime.parse(dateStr);
    final yesterday = parsed.subtract(const Duration(days: 1));
    return "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }
}
