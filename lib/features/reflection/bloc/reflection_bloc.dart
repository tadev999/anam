import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';

// EVENTS
abstract class ReflectionEvent {
  const ReflectionEvent();
}

class SaveReflectionRequested extends ReflectionEvent {
  final String prompt;
  final String content;

  const SaveReflectionRequested({
    required this.prompt,
    required this.content,
  });
}

class DiscardReflectionRequested extends ReflectionEvent {
  const DiscardReflectionRequested();
}

// STATES
abstract class ReflectionState {
  const ReflectionState();
}

class ReflectionInitial extends ReflectionState {}

class ReflectionLoading extends ReflectionState {}

class ReflectionSuccess extends ReflectionState {
  final String message;
  const ReflectionSuccess(this.message);
}

class ReflectionFailure extends ReflectionState {
  final String error;
  const ReflectionFailure(this.error);
}

// BLOC
class ReflectionBloc extends Bloc<ReflectionEvent, ReflectionState> {
  final BaseDatabaseRepository databaseRepository;

  ReflectionBloc({required this.databaseRepository}) : super(ReflectionInitial()) {
    on<SaveReflectionRequested>(_onSaveReflectionRequested);
    on<DiscardReflectionRequested>(_onDiscardReflectionRequested);
  }

  Future<void> _onSaveReflectionRequested(
    SaveReflectionRequested event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(ReflectionLoading());
    try {
      if (event.content.trim().length < 50) {
        emit(const ReflectionFailure("Nội dung chiêm nghiệm cần đạt tối thiểu 50 ký tự để lưu lại."));
        return;
      }
      await databaseRepository.saveReflection(event.prompt, event.content);
      emit(const ReflectionSuccess("Chiêm nghiệm đã được cất giữ vào góc riêng của bạn."));
    } catch (e) {
      emit(ReflectionFailure("Lỗi lưu bài viết: ${e.toString()}"));
    }
  }

  Future<void> _onDiscardReflectionRequested(
    DiscardReflectionRequested event,
    Emitter<ReflectionState> emit,
  ) async {
    emit(ReflectionLoading());
    try {
      // "Gửi vào hư vô" chỉ đơn giản là không lưu trữ gì
      emit(const ReflectionSuccess("Tâm tư đã được trả về với hư vô rộng lớn."));
    } catch (e) {
      emit(ReflectionFailure("Lỗi xả trôi: ${e.toString()}"));
    }
  }
}
