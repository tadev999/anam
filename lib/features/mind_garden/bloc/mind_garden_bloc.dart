import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/repositories/database_repository.dart';
import '../../daily_anchor/data/models/anchor_model.dart';

part 'mind_garden_event.dart';
part 'mind_garden_state.dart';

class MindGardenBloc extends Bloc<MindGardenEvent, MindGardenState> {
  final BaseDatabaseRepository databaseRepository;

  MindGardenBloc({required this.databaseRepository})
    : super(MindGardenInitial()) {
    on<LoadGardenRequested>(_onLoadGarden);
  }

  Future<void> _onLoadGarden(
    LoadGardenRequested event,
    Emitter<MindGardenState> emit,
  ) async {
    emit(MindGardenLoading());
    try {
      final now = event.month;
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final anchors = await databaseRepository.fetchMonthAnchors(
        event.uid,
        yearMonth,
      );
      emit(MindGardenSuccess(anchors: anchors, displayMonth: event.month));
    } catch (e) {
      emit(
        MindGardenFailure(
          errorMessage: 'Lỗi tải Khu Vườn Tâm trí: ${e.toString()}',
        ),
      );
    }
  }
}
