import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

// ==========================================
// 1. STATE DEFINITION
// ==========================================
class SilenceState extends Equatable {
  final int selectedDurationMinutes;
  final int secondsRemaining;
  final bool isTimerRunning;
  final bool isPlayingSound;
  final String currentSound;
  final bool isCompleted;

  const SilenceState({
    this.selectedDurationMinutes = 5,
    this.secondsRemaining = 300,
    this.isTimerRunning = false,
    this.isPlayingSound = false,
    this.currentSound = 'Mưa Rơi',
    this.isCompleted = false,
  });

  SilenceState copyWith({
    int? selectedDurationMinutes,
    int? secondsRemaining,
    bool? isTimerRunning,
    bool? isPlayingSound,
    String? currentSound,
    bool? isCompleted,
  }) {
    return SilenceState(
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
abstract class SilenceEvent extends Equatable {
  const SilenceEvent();
  @override
  List<Object?> get props => [];
}

class ChangeDurationRequested extends SilenceEvent {
  final int minutes;
  const ChangeDurationRequested(this.minutes);
  @override
  List<Object?> get props => [minutes];
}

class ToggleTimerRequested extends SilenceEvent {}

class ResetTimerRequested extends SilenceEvent {}

class _TimerTicked extends SilenceEvent {
  final int secondsRemaining;
  const _TimerTicked(this.secondsRemaining);
  @override
  List<Object?> get props => [secondsRemaining];
}

class ToggleSoundRequested extends SilenceEvent {}

class SelectSoundRequested extends SilenceEvent {
  final String soundName;
  final String soundUrl;
  const SelectSoundRequested({required this.soundName, required this.soundUrl});
  @override
  List<Object?> get props => [soundName, soundUrl];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class SilenceBloc extends Bloc<SilenceEvent, SilenceState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  SilenceBloc() : super(const SilenceState()) {
    on<ChangeDurationRequested>(_onChangeDurationRequested);
    on<ToggleTimerRequested>(_onToggleTimerRequested);
    on<ResetTimerRequested>(_onResetTimerRequested);
    on<_TimerTicked>(_onTimerTicked);
    on<ToggleSoundRequested>(_onToggleSoundRequested);
    on<SelectSoundRequested>(_onSelectSoundRequested);
  }

  void _onChangeDurationRequested(ChangeDurationRequested event, Emitter<SilenceState> emit) {
    _timer?.cancel();
    _audioPlayer.setVolume(1.0);
    emit(state.copyWith(
      selectedDurationMinutes: event.minutes,
      secondsRemaining: event.minutes * 60,
      isTimerRunning: false,
      isCompleted: false,
    ));
  }

  void _onToggleTimerRequested(ToggleTimerRequested event, Emitter<SilenceState> emit) {
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

  Future<void> _onResetTimerRequested(ResetTimerRequested event, Emitter<SilenceState> emit) async {
    _timer?.cancel();
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint("Lỗi dừng phát nhạc: $e");
    }
    _audioPlayer.setVolume(1.0);
    emit(state.copyWith(
      isTimerRunning: false,
      secondsRemaining: state.selectedDurationMinutes * 60,
      isCompleted: false,
      isPlayingSound: false,
    ));
  }

  void _onTimerTicked(_TimerTicked event, Emitter<SilenceState> emit) {
    if (event.secondsRemaining == 0) {
      _audioPlayer.stop();
      _audioPlayer.setVolume(1.0); // Reset volume for next play
      emit(state.copyWith(
        secondsRemaining: 0,
        isTimerRunning: false,
        isCompleted: true,
        isPlayingSound: false,
      ));
    } else {
      // Deterministic volume fade out in last 10 seconds of countdown
      if (event.secondsRemaining <= 10 && state.isPlayingSound) {
        final double targetVolume = event.secondsRemaining / 10.0;
        _audioPlayer.setVolume(targetVolume);
      }
      emit(state.copyWith(secondsRemaining: event.secondsRemaining));
    }
  }

  String _getSoundSource(String soundName) {
    switch (soundName) {
      case 'Tiếng Sóng':
        return 'assets/audio/waves.m4a';
      case 'Chuông Thiền':
        return 'assets/audio/bell.m4a';
      case 'Suối Rừng':
        return 'assets/audio/stream.m4a';
      case 'Mưa Rơi':
      default:
        return 'assets/audio/rain_sleep.m4a';
    }
  }

  String _getOnlineFallback(String source) {
    if (source.contains('waves')) {
      return 'https://archive.org/download/beachfront-ocean-waves-relaxing-nature-sounds-3-hours/Beachfront%20Ocean%20Waves%20-%20Relaxing%20Nature%20Sounds%203%20Hours.mp3';
    } else if (source.contains('fire')) {
      return 'https://archive.org/download/SSE_Library_FIRE/BURNING%2FFIREBurn_Heavy%20fire%20crackle_CS_USC.mp3';
    }
    return 'https://archive.org/download/soundrainforsleep/Sound%20Rain%20For%20Sleep.mp3';
  }

  Future<void> _playSource(String source) async {
    try {
      if (source.startsWith('assets/')) {
        await _audioPlayer.setAsset(source);
      } else {
        await _audioPlayer.setUrl(source);
      }
    } catch (e) {
      debugPrint("Asset load issue ($e), switching to online nature stream fallback...");
      final fallbackUrl = _getOnlineFallback(source);
      await _audioPlayer.setUrl(fallbackUrl);
    }
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  Future<void> _onToggleSoundRequested(ToggleSoundRequested event, Emitter<SilenceState> emit) async {
    try {
      if (state.isPlayingSound) {
        await _audioPlayer.stop();
        emit(state.copyWith(isPlayingSound: false));
      } else {
        emit(state.copyWith(isPlayingSound: true));
        _audioPlayer.setVolume(1.0);
        final soundSource = _getSoundSource(state.currentSound);
        await _playSource(soundSource);
        if (!state.isPlayingSound) {
          await _audioPlayer.stop();
          return;
        }
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Lỗi phát nhạc Silence: $e");
    }
  }

  Future<void> _onSelectSoundRequested(SelectSoundRequested event, Emitter<SilenceState> emit) async {
    try {
      _audioPlayer.setVolume(1.0);
      await _audioPlayer.stop();
      emit(state.copyWith(currentSound: event.soundName, isPlayingSound: true));
      final soundSource = event.soundUrl.isNotEmpty ? event.soundUrl : _getSoundSource(event.soundName);
      await _playSource(soundSource);
      if (!state.isPlayingSound) {
        await _audioPlayer.stop();
        return;
      }
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Lỗi phát nhạc Silence: $e");
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
