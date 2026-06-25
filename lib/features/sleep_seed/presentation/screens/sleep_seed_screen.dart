import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/sleep_seed_bloc.dart';
import '../../bloc/sleep_seed_event.dart';
import '../../bloc/sleep_seed_state.dart';

class SleepSeedScreen extends StatefulWidget {
  const SleepSeedScreen({super.key});

  @override
  State<SleepSeedScreen> createState() => _SleepSeedScreenState();
}

class _SleepSeedScreenState extends State<SleepSeedScreen> with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  
  // States for sowing interaction
  bool _isSowing = false;
  double _sowProgress = 0.0; // 0.0 to 1.0
  Timer? _sowTimer;
  Timer? _hapticTimer;

  // States for ambient player
  bool _sownCompleted = false;
  bool _isPlaying = false;
  String _selectedSoundId = 'rain';
  int _selectedDurationMinutes = 15; // default
  int _secondsRemaining = 900;
  Timer? _countdownTimer;
  bool _isFadeOutActive = false;

  // Ambient Night Mode (Pitch Black)
  bool _isNightMode = false;

  // Animation controllers
  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;
  late final AnimationController _seedGlowController;

  final List<Map<String, dynamic>> _sounds = [
    {
      'id': 'rain',
      'label': 'Tiếng mưa Anam',
      'icon': Icons.grain_outlined,
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'id': 'fire',
      'label': 'Bếp lửa an trú',
      'icon': Icons.local_fire_department_outlined,
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'id': 'wind',
      'label': 'Gió ngàn',
      'icon': Icons.air_outlined,
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
    },
    {
      'id': 'waves',
      'label': 'Sóng lặng',
      'icon': Icons.waves_outlined,
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'
    },
  ];

  final List<int> _durations = [1, 15, 30, 45, 60]; // 1 minute is for demo/testing

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Breathing guide animation (8s cycle)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // Seed glow animation
    _seedGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sowTimer?.cancel();
    _hapticTimer?.cancel();
    _countdownTimer?.cancel();
    _breathingController.dispose();
    _seedGlowController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sowing Interaction Logic
  // ---------------------------------------------------------------------------
  void _startSowing() {
    if (_sownCompleted) return;
    setState(() {
      _isSowing = true;
      _sowProgress = 0.0;
    });

    _hapticTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      HapticFeedback.lightImpact();
    });

    const int totalSteps = 30; // 3 seconds total (100ms per step)
    int currentStep = 0;
    _sowTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      currentStep++;
      setState(() {
        _sowProgress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        _completeSowing();
      }
    });
  }

  void _cancelSowing() {
    if (_sownCompleted) return;
    _sowTimer?.cancel();
    _hapticTimer?.cancel();
    setState(() {
      _isSowing = false;
      _sowProgress = 0.0;
    });
  }

  void _completeSowing() {
    _sowTimer?.cancel();
    _hapticTimer?.cancel();
    HapticFeedback.mediumImpact();
    
    // Dispatch Bloc Event
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is Authenticated) {
      final todayStr = _getTodayString();
      BlocProvider.of<SleepSeedBloc>(context).add(
        SowSleepSeedRequested(
          uid: authState.user.uid,
          date: todayStr,
          sownAt: DateTime.now(),
        ),
      );
    }

    setState(() {
      _sowProgress = 1.0;
      _isSowing = false;
      _sownCompleted = true;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });

    // Auto start playing audio
    _startPlaying();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // ---------------------------------------------------------------------------
  // Audio Player & Timer Logic
  // ---------------------------------------------------------------------------
  Future<void> _startPlaying() async {
    final sound = _sounds.firstWhere((s) => s['id'] == _selectedSoundId);
    try {
      setState(() {
        _isPlaying = true;
        _isFadeOutActive = false;
      });
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setUrl(sound['url']);
      await _audioPlayer.setLoopMode(LoopMode.one);
      _audioPlayer.play();

      _startTimer();
    } catch (e) {
      debugPrint("Lỗi phát nhạc Sleep: $e");
      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _stopPlaying() async {
    _countdownTimer?.cancel();
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });

        // Trigger fade out in the last 10 seconds
        if (_secondsRemaining <= 10 && !_isFadeOutActive) {
          _triggerFadeOut();
        }
      } else {
        _countdownTimer?.cancel();
        _stopPlaying();
      }
    });
  }

  void _triggerFadeOut() {
    _isFadeOutActive = true;
    double volume = 1.0;
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      volume -= 0.02; // 50 steps = 10 seconds
      if (volume <= 0) {
        timer.cancel();
        await _stopPlaying();
        await _audioPlayer.setVolume(1.0); // reset volume
        setState(() {
          _isFadeOutActive = false;
          _secondsRemaining = _selectedDurationMinutes * 60;
        });
      } else {
        await _audioPlayer.setVolume(volume);
      }
    });
  }

  void _changeDuration(int minutes) {
    setState(() {
      _selectedDurationMinutes = minutes;
      _secondsRemaining = minutes * 60;
    });
    if (_isPlaying) {
      _startTimer();
    }
  }

  void _changeSound(String soundId) {
    setState(() {
      _selectedSoundId = soundId;
    });
    if (_isPlaying) {
      _startPlaying();
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // ---------------------------------------------------------------------------
  // Build Methods
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SleepSeedBloc, SleepSeedState>(
      listener: (context, state) {
        if (state is SleepSeedFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF08080C),
        body: Stack(
          children: [
            // Dark gradient background
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF060608), Color(0xFF0C0E1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Aura glow behind seed
            Center(
              child: AnimatedBuilder(
                animation: _seedGlowController,
                builder: (context, child) {
                  return Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.sageGreen.withOpacity(
                        _isSowing 
                            ? (0.15 + _sowProgress * 0.15) 
                            : (0.05 + 0.03 * _seedGlowController.value)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ZenTheme.sageGreen.withOpacity(
                            _isSowing 
                                ? (0.2 + _sowProgress * 0.2) 
                                : (0.08 + 0.04 * _seedGlowController.value)
                          ),
                          blurRadius: 100,
                          spreadRadius: _isSowing ? 20 + _sowProgress * 30 : 10,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // Immersive content
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isNightMode 
                    ? _buildNightModeUI() 
                    : (_sownCompleted ? _buildPlayerUI(textTheme) : _buildSowUI(textTheme)),
              ),
            ),

            // Header close button (Hidden in Night Mode)
            if (!_isNightMode)
              Positioned(
                top: 50,
                left: 20,
                child: GestureDetector(
                  onTap: () {
                    _stopPlaying();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white60, size: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 1. Phân cảnh gieo hạt (Sowing Phase)
  Widget _buildSowUI(TextTheme textTheme) {
    return Column(
      key: const ValueKey('sow_ui'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 70),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              Text(
                'Hạt mầm ngủ ngon',
                textAlign: TextAlign.center,
                style: textTheme.displayMedium!.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: ZenTheme.creamWhite,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Không cần điểm số, không cần đo lường.\nChỉ cần chạm giữ để gieo hạt, buông bỏ suy nghĩ và cho phép cơ thể nghỉ ngơi.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGray.withOpacity(0.7),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        
        // Touch holding area
        Center(
          child: GestureDetector(
            onLongPressStart: (_) => _startSowing(),
            onLongPressEnd: (_) => _cancelSowing(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress circle outline
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: _sowProgress,
                    strokeWidth: 2,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(ZenTheme.sageGreen),
                  ),
                ),
                
                // Seed glowing button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isSowing ? 110 : 120,
                  height: _isSowing ? 110 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_isSowing ? 0.08 : 0.03),
                    border: Border.all(
                      color: ZenTheme.sageGreen.withOpacity(_isSowing ? 0.4 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.spa_outlined,
                      color: ZenTheme.sageGreen,
                      size: 44,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isSowing ? 'Đang gieo mầm bình yên...' : 'Chạm và giữ 3 giây để gieo hạt',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium!.copyWith(
            color: _isSowing ? ZenTheme.sageGreen : ZenTheme.softGray.withOpacity(0.5),
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        
        const Spacer(),
        const SizedBox(height: 60),
      ],
    );
  }

  // 2. Phân cảnh trình phát nhạc & thư giãn (Player Phase)
  Widget _buildPlayerUI(TextTheme textTheme) {
    return SingleChildScrollView(
      key: const ValueKey('player_ui'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 70),
          
          // Pulsing Breathing Dot
          Center(
            child: ScaleTransition(
              scale: _breathingAnimation,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.sageGreen.withOpacity(0.12),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.nights_stay,
                    color: ZenTheme.sageGreen,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          
          Text(
            'Hạt mầm đã gieo yên bình',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium!.copyWith(
              color: ZenTheme.sageGreen,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_secondsRemaining),
            textAlign: TextAlign.center,
            style: textTheme.displayLarge!.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              color: ZenTheme.creamWhite,
            ),
          ),
          const SizedBox(height: 32),

          // Play/Stop Button
          Center(
            child: GestureDetector(
              onTap: () {
                if (_isPlaying) {
                  _stopPlaying();
                } else {
                  _startPlaying();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.sageGreen.withOpacity(0.15),
                  border: Border.all(color: ZenTheme.sageGreen.withOpacity(0.3)),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: ZenTheme.sageGreen,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // 1. Selector Sound Card
          Text(
            'Âm thanh ru ngủ',
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.softGray.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sounds.map((sound) {
              final isSelected = sound['id'] == _selectedSoundId;
              return GestureDetector(
                onTap: () => _changeSound(sound['id']),
                child: GlassContainer(
                  opacity: isSelected ? 0.12 : 0.03,
                  border: Border.all(
                    color: isSelected
                        ? ZenTheme.sageGreen.withOpacity(0.4)
                        : Colors.white.withOpacity(0.08),
                  ),
                  radius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sound['icon'] as IconData,
                        color: isSelected ? ZenTheme.sageGreen : ZenTheme.softGray,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sound['label'] as String,
                        style: TextStyle(
                          color: isSelected ? ZenTheme.creamWhite : ZenTheme.softGray,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 2. Timer Duration Card
          Text(
            'Hẹn giờ tự tắt',
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.softGray.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _durations.map((duration) {
              final isSelected = duration == _selectedDurationMinutes;
              final label = duration == 1 ? "1m Demo" : "${duration}m";
              return GestureDetector(
                onTap: () => _changeDuration(duration),
                child: GlassContainer(
                  opacity: isSelected ? 0.12 : 0.03,
                  border: Border.all(
                    color: isSelected
                        ? ZenTheme.sageGreen.withOpacity(0.4)
                        : Colors.white.withOpacity(0.08),
                  ),
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? ZenTheme.creamWhite : ZenTheme.softGray,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),

          // 3. Ambient Night Mode Button (Bảo vệ mắt / Pitch Black)
          ZenButton.glass(
            text: 'Vào giấc ngủ (Màn hình tối)',
            onPressed: () {
              setState(() {
                _isNightMode = true;
              });
              // Set status bar to dim
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // 3. Chế độ ban đêm (Pitch Black Mode)
  Widget _buildNightModeUI() {
    return GestureDetector(
      key: const ValueKey('night_ui'),
      onTap: () {
        setState(() {
          _isNightMode = false;
        });
        // Restore status bar
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      child: Container(
        color: const Color(0xFF040406),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Extra-dim pulsing breathing dot
            ScaleTransition(
              scale: _breathingAnimation,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.sageGreen.withOpacity(0.015),
                  boxShadow: [
                    BoxShadow(
                      color: ZenTheme.sageGreen.withOpacity(0.01),
                      blurRadius: 40,
                      spreadRadius: 5,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Chạm bất kỳ đâu để đánh thức màn hình',
              style: TextStyle(
                color: Colors.white.withOpacity(0.08),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            )
          ],
        ),
      ),
    );
  }
}
