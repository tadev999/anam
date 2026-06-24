import 'package:flutter_test/flutter_test.dart';
import 'package:anam/features/mind_garden/bloc/mind_garden_bloc.dart';
import 'package:anam/core/repositories/database_repository.dart';
import 'package:anam/features/daily_anchor/data/models/anchor_model.dart';

/// Class Mock đơn giản để kiểm thử repository ngoại tuyến
class MockSimpleDatabaseRepository extends MockDatabaseRepository {
  final List<AnchorModel> _anchors;
  final bool shouldFail;

  MockSimpleDatabaseRepository(this._anchors, {this.shouldFail = false});

  @override
  Future<List<AnchorModel>> fetchMonthAnchors(String uid, String yearMonth) async {
    if (shouldFail) {
      throw Exception("Lỗi kết nối cơ sở dữ liệu");
    }
    return _anchors;
  }
}

void main() {
  group('MindGardenBloc Unit Tests', () {
    late List<AnchorModel> dummyAnchors;

    setUp(() {
      dummyAnchors = [
        AnchorModel(
          id: 'test_anchor_id',
          uid: 'user_test_123',
          date: '2026-06-24',
          affirmationText: 'Hôm nay tôi trân trọng giây phút hiện tại.',
          microOfferingId: 'breathe',
          intention: 'Lắng nghe cơ thể',
          morningCompleted: true,
          eveningCompleted: true,
          eveningEmotion: 'peaceful',
          eveningNote: 'Một ngày làm việc nhẹ nhàng',
        ),
      ];
    });

    test('Kiểm tra BLoC phát ra trạng thái Loading và Success khi tải thành công', () {
      final mockRepo = MockSimpleDatabaseRepository(dummyAnchors);
      final bloc = MindGardenBloc(databaseRepository: mockRepo);
      final testMonth = DateTime(2026, 6, 24);

      final expectedStates = [
        MindGardenLoading(),
        MindGardenSuccess(anchors: dummyAnchors, displayMonth: testMonth),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(LoadGardenRequested(uid: 'user_test_123', month: testMonth));
    });

    test('Kiểm tra BLoC phát ra trạng thái Loading và Failure khi gặp sự cố', () {
      final mockRepo = MockSimpleDatabaseRepository(dummyAnchors, shouldFail: true);
      final bloc = MindGardenBloc(databaseRepository: mockRepo);
      final testMonth = DateTime(2026, 6, 24);

      final expectedStates = [
        MindGardenLoading(),
        isA<MindGardenFailure>(),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));

      bloc.add(LoadGardenRequested(uid: 'user_test_123', month: testMonth));
    });
  });
}
