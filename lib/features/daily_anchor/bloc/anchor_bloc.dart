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

class FetchYesterdayAnchorRequested extends AnchorEvent {
  final String uid;
  final String yesterdayDate;
  const FetchYesterdayAnchorRequested(this.uid, this.yesterdayDate);
  @override
  List<Object?> get props => [uid, yesterdayDate];
}

class MarkIntentionReviewedRequested extends AnchorEvent {
  final String uid;
  final String date;
  final bool achieved;
  const MarkIntentionReviewedRequested(this.uid, this.date, this.achieved);
  @override
  List<Object?> get props => [uid, date, achieved];
}

class CompleteEveningReflectionRequested extends AnchorEvent {
  final String uid;
  final String date;
  final String emotion;
  final String note;
  final bool intentionAchieved;
  const CompleteEveningReflectionRequested({
    required this.uid,
    required this.date,
    required this.emotion,
    required this.note,
    required this.intentionAchieved,
  });
  @override
  List<Object?> get props => [uid, date, emotion, note, intentionAchieved];
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

class YesterdayAnchorLoaded extends AnchorState {
  final AnchorModel? anchor;
  const YesterdayAnchorLoaded(this.anchor);
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

class EveningReflectionSuccess extends AnchorState {
  final AnchorModel anchor;
  const EveningReflectionSuccess(this.anchor);
  @override
  List<Object?> get props => [anchor];
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
    on<FetchYesterdayAnchorRequested>(_onFetchYesterdayAnchorRequested);
    on<MarkIntentionReviewedRequested>(_onMarkIntentionReviewedRequested);
    on<CompleteEveningReflectionRequested>(_onCompleteEveningReflectionRequested);
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

  Future<void> _onFetchYesterdayAnchorRequested(
    FetchYesterdayAnchorRequested event,
    Emitter<AnchorState> emit,
  ) async {
    try {
      final anchor = await _databaseRepository.fetchYesterdayAnchor(event.uid, event.yesterdayDate);
      emit(YesterdayAnchorLoaded(anchor));
    } catch (e) {
      emit(YesterdayAnchorLoaded(null)); // Không làm gãy flow chính
    }
  }

  Future<void> _onMarkIntentionReviewedRequested(
    MarkIntentionReviewedRequested event,
    Emitter<AnchorState> emit,
  ) async {
    try {
      await _databaseRepository.markIntentionReviewed(event.uid, event.date, event.achieved);
    } catch (_) {
      // Silent fail — không block UX
    }
  }

  Future<void> _onCompleteEveningReflectionRequested(
    CompleteEveningReflectionRequested event,
    Emitter<AnchorState> emit,
  ) async {
    emit(AnchorLoading());
    try {
      final anchor = await _databaseRepository.completeEveningReflection(
        event.uid, event.date, event.emotion, event.note, event.intentionAchieved,
      );
      emit(EveningReflectionSuccess(anchor));
    } catch (e) {
      emit(AnchorFailure(e.toString()));
    }
  }
}
