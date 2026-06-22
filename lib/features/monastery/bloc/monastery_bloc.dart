import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

// ==========================================
// 1. STATE DEFINITION
// ==========================================
class MonasteryState extends Equatable {
  final int selectedDurationMinutes;
  final int secondsRemaining;
  final bool isTimerRunning;
  final bool isPlayingSound;
  final String currentSound;
  final bool isCompleted;

  const MonasteryState({
    this.selectedDurationMinutes = 5,
    this.secondsRemaining = 300,
    this.isTimerRunning = false,
    this.isPlayingSound = false,
    this.currentSound = 'Mưa Rơi',
    this.isCompleted = false,
  });

  MonasteryState copyWith({
    int? selectedDurationMinutes,
    int? secondsRemaining,
    bool? isTimerRunning,
    bool? isPlayingSound,
    String? currentSound,
    bool? isCompleted,
  }) {
    return MonasteryState(
      selectedDurationMinutes: selectedDurationMinutes ?? this.selectedDurationMinutes,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isPlayingSound: isPlayingSound ?? this.isPlayingSound,
      currentSound: currentSound ?? this.currentSound,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        selectedDurationMinutes,
        secondsRemaining,
        isTimerRunning,
        isPlayingSound,
        currentSound,
        isCompleted,
      ];
}

// ==========================================
// 2. EVENTS
// ==========================================
abstract class MonasteryEvent extends Equatable {
  const MonasteryEvent();
  @override
  List<Object?> get props => [];
}

class ChangeDurationRequested extends MonasteryEvent {
  final int minutes;
  const ChangeDurationRequested(this.minutes);
  @override
  List<Object?> get props => [minutes];
}

class ToggleTimerRequested extends MonasteryEvent {}

class ResetTimerRequested extends MonasteryEvent {}

class _TimerTicked extends MonasteryEvent {
  final int secondsRemaining;
  const _TimerTicked(this.secondsRemaining);
  @override
  List<Object?> get props => [secondsRemaining];
}

class ToggleSoundRequested extends MonasteryEvent {}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class MonasteryBloc extends Bloc<MonasteryEvent, MonasteryState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  MonasteryBloc() : super(const MonasteryState()) {
    on<ChangeDurationRequested>(_onChangeDurationRequested);
    on<ToggleTimerRequested>(_onToggleTimerRequested);
    on<ResetTimerRequested>(_onResetTimerRequested);
    on<_TimerTicked>(_onTimerTicked);
    on<ToggleSoundRequested>(_onToggleSoundRequested);
  }

  void _onChangeDurationRequested(ChangeDurationRequested event, Emitter<MonasteryState> emit) {
    _timer?.cancel();
    emit(state.copyWith(
      selectedDurationMinutes: event.minutes,
      secondsRemaining: event.minutes * 60,
      isTimerRunning: false,
      isCompleted: false,
    ));
  }

  void _onToggleTimerRequested(ToggleTimerRequested event, Emitter<MonasteryState> emit) {
    if (state.isTimerRunning) {
      _timer?.cancel();
      emit(state.copyWith(isTimerRunning: false));
    } else {
      emit(state.copyWith(isTimerRunning: true, isCompleted: false));
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.secondsRemaining > 0) {
          add(_TimerTicked(state.secondsRemaining - 1));
        } else {
          _timer?.cancel();
          add(const _TimerTicked(0));
        }
      });
    }
  }

  void _onResetTimerRequested(ResetTimerRequested event, Emitter<MonasteryState> emit) {
    _timer?.cancel();
    emit(state.copyWith(
      isTimerRunning: false,
      secondsRemaining: state.selectedDurationMinutes * 60,
      isCompleted: false,
    ));
  }

  void _onTimerTicked(_TimerTicked event, Emitter<MonasteryState> emit) {
    if (event.secondsRemaining == 0) {
      emit(state.copyWith(
        secondsRemaining: 0,
        isTimerRunning: false,
        isCompleted: true,
      ));
    } else {
      emit(state.copyWith(secondsRemaining: event.secondsRemaining));
    }
  }

  Future<void> _onToggleSoundRequested(ToggleSoundRequested event, Emitter<MonasteryState> emit) async {
    try {
      if (state.isPlayingSound) {
        await _audioPlayer.stop();
        emit(state.copyWith(isPlayingSound: false));
      } else {
        emit(state.copyWith(isPlayingSound: true));
        // Mô phỏng phát nhạc thiền an toàn qua public URL
        await _audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Lỗi phát nhạc Monastery: $e");
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
