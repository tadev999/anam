import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/database_repository.dart';
import '../../release_space/data/models/release_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class HearthEvent extends Equatable {
  const HearthEvent();
  @override
  List<Object?> get props => [];
}

class LoadReleasesRequested extends HearthEvent {}

class SendHugRequested extends HearthEvent {
  final String releaseId;
  final String senderUid;
  const SendHugRequested(this.releaseId, this.senderUid);
  @override
  List<Object?> get props => [releaseId, senderUid];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class HearthState extends Equatable {
  const HearthState();
  @override
  List<Object?> get props => [];
}

class HearthInitial extends HearthState {}

class HearthLoading extends HearthState {}

class HearthLoaded extends HearthState {
  final List<ReleaseModel> releases;
  final String? justSupportedReleaseId; // Ghi nhận ID release vừa được ôm thành công
  
  const HearthLoaded(this.releases, {this.justSupportedReleaseId});
  
  @override
  List<Object?> get props => [releases, justSupportedReleaseId];
}

class HearthFailure extends HearthState {
  final String message;
  const HearthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class HearthBloc extends Bloc<HearthEvent, HearthState> {
  final BaseDatabaseRepository _databaseRepository;

  HearthBloc({required BaseDatabaseRepository databaseRepository})
      : _databaseRepository = databaseRepository,
        super(HearthInitial()) {
    on<LoadReleasesRequested>(_onLoadReleasesRequested);
    on<SendHugRequested>(_onSendHugRequested);
  }

  Future<void> _onLoadReleasesRequested(
    LoadReleasesRequested event,
    Emitter<HearthState> emit,
  ) async {
    emit(HearthLoading());
    try {
      final list = await _databaseRepository.fetchReleases();
      emit(HearthLoaded(list));
    } catch (e) {
      emit(HearthFailure(e.toString()));
    }
  }

  Future<void> _onSendHugRequested(
    SendHugRequested event,
    Emitter<HearthState> emit,
  ) async {
    // Không chuyển sang trạng thái loading để tránh việc nhấp nháy cả danh sách
    final currentState = state;
    if (currentState is HearthLoaded) {
      try {
        final updated = await _databaseRepository.sendVirtualHug(event.releaseId, event.senderUid);
        if (updated != null) {
          final updatedList = currentState.releases.map((c) {
            return c.id == event.releaseId ? updated : c;
          }).toList();
          emit(HearthLoaded(updatedList, justSupportedReleaseId: event.releaseId));
        }
      } catch (e) {
        emit(HearthFailure(e.toString()));
      }
    }
  }
}
