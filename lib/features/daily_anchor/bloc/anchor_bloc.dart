import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../data/models/anchor_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class AnchorEvent extends Equatable {
  const AnchorEvent();
  @override
  List<Object?> get props => [];
}

class CheckTodayAnchorRequested extends AnchorEvent {
  final String uid;
  final String date;
  const CheckTodayAnchorRequested(this.uid, this.date);
  @override
  List<Object?> get props => [uid, date];
}

class CompleteTodayAnchorRequested extends AnchorEvent {
  final String uid;
  final String date;
  final String affirmation;
  final String microOfferingId;
  final String intention;
  // Trạng thái cảm xúc được người dùng chọn ở bước Check-In.
  // Nullable vì người dùng có thể đang hoàn thành anchor từ state cũ (đã loaded).
  final String? emotionCheckIn;

  const CompleteTodayAnchorRequested({
    required this.uid,
    required this.date,
    required this.affirmation,
    required this.microOfferingId,
    required this.intention,
    this.emotionCheckIn,
  });

  @override
  List<Object?> get props => [uid, date, affirmation, microOfferingId, intention, emotionCheckIn];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class AnchorState extends Equatable {
  const AnchorState();
  @override
  List<Object?> get props => [];
}

class AnchorInitial extends AnchorState {}

class AnchorLoading extends AnchorState {}

class AnchorLoadSuccess extends AnchorState {
  final AnchorModel? anchor;
  const AnchorLoadSuccess(this.anchor);
  @override
  List<Object?> get props => [anchor];
}

class AnchorSubmissionSuccess extends AnchorState {
  final AnchorModel anchor;
  const AnchorSubmissionSuccess(this.anchor);
  @override
  List<Object?> get props => [anchor];
}

class AnchorFailure extends AnchorState {
  final String message;
  const AnchorFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class AnchorBloc extends Bloc<AnchorEvent, AnchorState> {
  final BaseDatabaseRepository _databaseRepository;

  AnchorBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(AnchorInitial()) {
    on<CheckTodayAnchorRequested>(_onCheckTodayAnchorRequested);
    on<CompleteTodayAnchorRequested>(_onCompleteTodayAnchorRequested);
  }

  Future<void> _onCheckTodayAnchorRequested(
    CheckTodayAnchorRequested event,
    Emitter<AnchorState> emit,
  ) async {
    emit(AnchorLoading());
    try {
      final anchor = await _databaseRepository.fetchTodayAnchor(event.uid, event.date);
      emit(AnchorLoadSuccess(anchor));
    } catch (e) {
      emit(AnchorFailure(e.toString()));
    }
  }

  Future<void> _onCompleteTodayAnchorRequested(
    CompleteTodayAnchorRequested event,
    Emitter<AnchorState> emit,
  ) async {
    emit(AnchorLoading());
    try {
      final anchor = await _databaseRepository.completeTodayAnchor(
        event.uid,
        event.date,
        event.affirmation,
        event.microOfferingId,
        event.intention,
        emotionCheckIn: event.emotionCheckIn,
      );
      emit(AnchorSubmissionSuccess(anchor));
    } catch (e) {
      emit(AnchorFailure(e.toString()));
    }
  }
}
