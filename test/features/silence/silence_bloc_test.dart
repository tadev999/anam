import 'package:flutter_test/flutter_test.dart';
import 'package:anam/features/silence/bloc/silence_bloc.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock just_audio platform channel to avoid MissingPluginException
  const MethodChannel channel = MethodChannel('com.ryanheise.just_audio.methods');
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'init') {
        return {
          'duration': -1,
        };
      }
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SilenceBloc Unit Tests', () {
    late SilenceBloc silenceBloc;

    setUp(() {
      silenceBloc = SilenceBloc();
    });

    tearDown(() {
      silenceBloc.close();
    });

    test('Initial State should have correct defaults', () {
      expect(silenceBloc.state.selectedDurationMinutes, 5);
      expect(silenceBloc.state.secondsRemaining, 300);
      expect(silenceBloc.state.isTimerRunning, false);
      expect(silenceBloc.state.isPlayingSound, false);
      expect(silenceBloc.state.currentSound, 'Mưa Rơi');
      expect(silenceBloc.state.isCompleted, false);
    });

    test('ChangeDurationRequested updates selected duration and seconds remaining', () {
      final expectedStates = [
        const SilenceState(
          selectedDurationMinutes: 10,
          secondsRemaining: 600,
          isTimerRunning: false,
          isCompleted: false,
          isPlayingSound: false,
        ),
      ];

      expectLater(silenceBloc.stream, emitsInOrder(expectedStates));
      silenceBloc.add(const ChangeDurationRequested(10));
    });

    test('ResetTimerRequested stops timer and turns off playing sound state', () {
      final expectedStates = [
        const SilenceState(
          selectedDurationMinutes: 5,
          secondsRemaining: 300,
          isTimerRunning: false,
          isCompleted: false,
          isPlayingSound: false,
        ),
      ];

      expectLater(silenceBloc.stream, emitsInOrder(expectedStates));
      silenceBloc.add(ResetTimerRequested());
    });
  });
}
