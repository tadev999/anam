import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../data/models/release_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class ReleaseEvent extends Equatable {
  const ReleaseEvent();
  @override
  List<Object?> get props => [];
}

class SubmitReleaseRequested extends ReleaseEvent {
  final String content;
  const SubmitReleaseRequested(this.content);
  @override
  List<Object?> get props => [content];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class ReleaseState extends Equatable {
  const ReleaseState();
  @override
  List<Object?> get props => [];
}

class ReleaseInitial extends ReleaseState {}

class ReleaseLoading extends ReleaseState {}

class ReleaseSuccess extends ReleaseState {
  final ReleaseModel release;
  const ReleaseSuccess(this.release);
  @override
  List<Object?> get props => [release];
}

class ReleaseFailure extends ReleaseState {
  final String message;
  const ReleaseFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class ReleaseBloc extends Bloc<ReleaseEvent, ReleaseState> {
  final BaseDatabaseRepository _databaseRepository;

  ReleaseBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(ReleaseInitial()) {
    on<SubmitReleaseRequested>(_onSubmitReleaseRequested);
  }

  Future<void> _onSubmitReleaseRequested(
    SubmitReleaseRequested event,
    Emitter<ReleaseState> emit,
  ) async {
    emit(ReleaseLoading());
    try {
      final release = await _databaseRepository.addRelease(event.content);
      emit(ReleaseSuccess(release));
    } catch (e) {
      emit(ReleaseFailure(e.toString()));
    }
  }
}
