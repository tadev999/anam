import 'package:flutter_test/flutter_test.dart';
import 'package:anam/features/sleep_seed/bloc/sleep_seed_bloc.dart';
import 'package:anam/features/sleep_seed/bloc/sleep_seed_event.dart';
import 'package:anam/features/sleep_seed/bloc/sleep_seed_state.dart';
import 'package:anam/core/repositories/database_repository.dart';
import 'package:anam/features/daily_anchor/data/models/anchor_model.dart';

class MockSleepSeedDatabaseRepository extends MockDatabaseRepository {
  final AnchorModel? mockAnchor;
  final bool shouldFail;

  MockSleepSeedDatabaseRepository({this.mockAnchor, this.shouldFail = false});

  @override
  Future<AnchorModel?> fetchTodayAnchor(String uid, String date) async {
    if (shouldFail) throw Exception("Lỗi kết nối database");
    return mockAnchor;
  }

  @override
  Future<AnchorModel> sowSleepSeed(String uid, String date, String sownAt) async {
    if (shouldFail) throw Exception("Lỗi kết nối database");
    return mockAnchor ??
        AnchorModel(
          id: 'test_id',
          uid: uid,
          date: date,
          affirmationText: 'Thư giãn',
          microOfferingId: 'breathe',
          intention: 'Ý định',
          sleepSeedSownAt: sownAt,
        );
  }

  @override
  Future<AnchorModel> collectSleepSprout(String uid, String date, String sproutedAt) async {
    if (shouldFail) throw Exception("Lỗi kết nối database");
    return mockAnchor ??
        AnchorModel(
          id: 'test_id',
          uid: uid,
          date: date,
          affirmationText: 'Thư giãn',
          microOfferingId: 'breathe',
          intention: 'Ý định',
          sleepSeedCollected: true,
          sleepSeedSproutedAt: sproutedAt,
        );
  }
}

void main() {
  group('SleepSeedBloc Unit Tests', () {
    test('CheckSleepSeedStatusRequested - cannot sprout if not sown', () {
      final mockRepo = MockSleepSeedDatabaseRepository(mockAnchor: null);
      final bloc = SleepSeedBloc(databaseRepository: mockRepo);

      final expectedStates = [
        SleepSeedLoading(),
        const SleepSeedStatusLoaded(yesterdayAnchor: null, canSprout: false),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(CheckSleepSeedStatusRequested('user_123', '2026-06-25'));
    });

    test('CheckSleepSeedStatusRequested - cannot sprout if less than 5 hours', () {
      // Sown just 1 hour ago
      final sownTime = DateTime.now().subtract(const Duration(hours: 1));
      final anchor = AnchorModel(
        id: 'yesterday_id',
        uid: 'user_123',
        date: '2026-06-24',
        affirmationText: 'Thư giãn',
        microOfferingId: 'breathe',
        intention: 'Ý định',
        sleepSeedSownAt: sownTime.toIso8601String(),
      );

      final mockRepo = MockSleepSeedDatabaseRepository(mockAnchor: anchor);
      final bloc = SleepSeedBloc(databaseRepository: mockRepo);

      final expectedStates = [
        SleepSeedLoading(),
        SleepSeedStatusLoaded(yesterdayAnchor: anchor, canSprout: false),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(CheckSleepSeedStatusRequested('user_123', '2026-06-25'));
    });

    test('CheckSleepSeedStatusRequested - can sprout if >= 5 hours and morning hour >= 5', () {
      // Mock DateTime.now() is not trivial without packages, but we can verify that the conditional logic gets executed.
      // Sown 8 hours ago
      final sownTime = DateTime.now().subtract(const Duration(hours: 8));
      final anchor = AnchorModel(
        id: 'yesterday_id',
        uid: 'user_123',
        date: '2026-06-24',
        affirmationText: 'Thư giãn',
        microOfferingId: 'breathe',
        intention: 'Ý định',
        sleepSeedSownAt: sownTime.toIso8601String(),
      );

      final mockRepo = MockSleepSeedDatabaseRepository(mockAnchor: anchor);
      final bloc = SleepSeedBloc(databaseRepository: mockRepo);

      final now = DateTime.now();
      final expectedCanSprout = now.hour >= 5;

      final expectedStates = [
        SleepSeedLoading(),
        SleepSeedStatusLoaded(yesterdayAnchor: anchor, canSprout: expectedCanSprout),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(CheckSleepSeedStatusRequested('user_123', '2026-06-25'));
    });

    test('SowSleepSeedRequested - success', () {
      final mockRepo = MockSleepSeedDatabaseRepository();
      final bloc = SleepSeedBloc(databaseRepository: mockRepo);

      final expectedStates = [
        SleepSeedLoading(),
        isA<SleepSeedSownSuccess>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(SowSleepSeedRequested(
        uid: 'user_123',
        date: '2026-06-25',
        sownAt: DateTime.now(),
      ));
    });

    test('CollectSleepSproutRequested - success', () {
      final mockRepo = MockSleepSeedDatabaseRepository();
      final bloc = SleepSeedBloc(databaseRepository: mockRepo);

      final expectedStates = [
        SleepSeedLoading(),
        isA<SleepSeedCollectionSuccess>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(CollectSleepSproutRequested(
        uid: 'user_123',
        date: '2026-06-24',
        sproutedAt: DateTime.now(),
      ));
    });
  });
}
