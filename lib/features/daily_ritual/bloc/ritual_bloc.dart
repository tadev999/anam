import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../data/models/ritual_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class RitualEvent extends Equatable {
  const RitualEvent();
  @override
  List<Object?> get props => [];
}

class CheckTodayRitualRequested extends RitualEvent {
  final String uid;
  final String date;
  const CheckTodayRitualRequested(this.uid, this.date);
  @override
  List<Object?> get props => [uid, date];
}

class CompleteTodayRitualRequested extends RitualEvent {
  final String uid;
  final String date;
  final String affirmation;
  final String microOfferingId;
  final String intention;

  const CompleteTodayRitualRequested({
    required this.uid,
    required this.date,
    required this.affirmation,
    required this.microOfferingId,
    required this.intention,
  });

  @override
  List<Object?> get props => [uid, date, affirmation, microOfferingId, intention];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class RitualState extends Equatable {
  const RitualState();
  @override
  List<Object?> get props => [];
}

class RitualInitial extends RitualState {}

class RitualLoading extends RitualState {}

class RitualLoadSuccess extends RitualState {
  final RitualModel? ritual;
  const RitualLoadSuccess(this.ritual);
  @override
  List<Object?> get props => [ritual];
}

class RitualSubmissionSuccess extends RitualState {
  final RitualModel ritual;
  const RitualSubmissionSuccess(this.ritual);
  @override
  List<Object?> get props => [ritual];
}

class RitualFailure extends RitualState {
  final String message;
  const RitualFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class RitualBloc extends Bloc<RitualEvent, RitualState> {
  final BaseDatabaseRepository _databaseRepository;

  RitualBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(RitualInitial()) {
    on<CheckTodayRitualRequested>(_onCheckTodayRitualRequested);
    on<CompleteTodayRitualRequested>(_onCompleteTodayRitualRequested);
  }

  Future<void> _onCheckTodayRitualRequested(
    CheckTodayRitualRequested event,
    Emitter<RitualState> emit,
  ) async {
    emit(RitualLoading());
    try {
      final ritual = await _databaseRepository.fetchTodayRitual(event.uid, event.date);
      emit(RitualLoadSuccess(ritual));
    } catch (e) {
      emit(RitualFailure(e.toString()));
    }
  }

  Future<void> _onCompleteTodayRitualRequested(
    CompleteTodayRitualRequested event,
    Emitter<RitualState> emit,
  ) async {
    emit(RitualLoading());
    try {
      final ritual = await _databaseRepository.completeTodayRitual(
        event.uid,
        event.date,
        event.affirmation,
        event.microOfferingId,
        event.intention,
      );
      emit(RitualSubmissionSuccess(ritual));
    } catch (e) {
      emit(RitualFailure(e.toString()));
    }
  }
}
