import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../../confessional/data/models/confession_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class TribeEvent extends Equatable {
  const TribeEvent();
  @override
  List<Object?> get props => [];
}

class LoadConfessionsRequested extends TribeEvent {}

class SendHugRequested extends TribeEvent {
  final String confessionId;
  final String senderUid;
  const SendHugRequested(this.confessionId, this.senderUid);
  @override
  List<Object?> get props => [confessionId, senderUid];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class TribeState extends Equatable {
  const TribeState();
  @override
  List<Object?> get props => [];
}

class TribeInitial extends TribeState {}

class TribeLoading extends TribeState {}

class TribeLoaded extends TribeState {
  final List<ConfessionModel> confessions;
  final String? justSupportedConfessionId; // Ghi nhận ID confession vừa được ôm thành công
  
  const TribeLoaded(this.confessions, {this.justSupportedConfessionId});
  
  @override
  List<Object?> get props => [confessions, justSupportedConfessionId];
}

class TribeFailure extends TribeState {
  final String message;
  const TribeFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class TribeBloc extends Bloc<TribeEvent, TribeState> {
  final BaseDatabaseRepository _databaseRepository;

  TribeBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(TribeInitial()) {
    on<LoadConfessionsRequested>(_onLoadConfessionsRequested);
    on<SendHugRequested>(_onSendHugRequested);
  }

  Future<void> _onLoadConfessionsRequested(
    LoadConfessionsRequested event,
    Emitter<TribeState> emit,
  ) async {
    emit(TribeLoading());
    try {
      final list = await _databaseRepository.fetchConfessions();
      emit(TribeLoaded(list));
    } catch (e) {
      emit(TribeFailure(e.toString()));
    }
  }

  Future<void> _onSendHugRequested(
    SendHugRequested event,
    Emitter<TribeState> emit,
  ) async {
    // Không chuyển sang trạng thái loading để tránh việc nhấp nháy cả danh sách
    final currentState = state;
    if (currentState is TribeLoaded) {
      try {
        final updated = await _databaseRepository.sendVirtualHug(event.confessionId, event.senderUid);
        if (updated != null) {
          final updatedList = currentState.confessions.map((c) {
            return c.id == event.confessionId ? updated : c;
          }).toList();
          emit(TribeLoaded(updatedList, justSupportedConfessionId: event.confessionId));
        }
      } catch (e) {
        emit(TribeFailure(e.toString()));
      }
    }
  }
}
