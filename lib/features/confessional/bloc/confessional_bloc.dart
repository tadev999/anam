import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../data/models/confession_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class ConfessionalEvent extends Equatable {
  const ConfessionalEvent();
  @override
  List<Object?> get props => [];
}

class SubmitConfessionRequested extends ConfessionalEvent {
  final String content;
  const SubmitConfessionRequested(this.content);
  @override
  List<Object?> get props => [content];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class ConfessionalState extends Equatable {
  const ConfessionalState();
  @override
  List<Object?> get props => [];
}

class ConfessionalInitial extends ConfessionalState {}

class ConfessionalLoading extends ConfessionalState {}

class ConfessionalSuccess extends ConfessionalState {
  final ConfessionModel confession;
  const ConfessionalSuccess(this.confession);
  @override
  List<Object?> get props => [confession];
}

class ConfessionalFailure extends ConfessionalState {
  final String message;
  const ConfessionalFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class ConfessionalBloc extends Bloc<ConfessionalEvent, ConfessionalState> {
  final BaseDatabaseRepository _databaseRepository;

  ConfessionalBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(ConfessionalInitial()) {
    on<SubmitConfessionRequested>(_onSubmitConfessionRequested);
  }

  Future<void> _onSubmitConfessionRequested(
    SubmitConfessionRequested event,
    Emitter<ConfessionalState> emit,
  ) async {
    emit(ConfessionalLoading());
    try {
      final confession = await _databaseRepository.addConfession(event.content);
      emit(ConfessionalSuccess(confession));
    } catch (e) {
      emit(ConfessionalFailure(e.toString()));
    }
  }
}
