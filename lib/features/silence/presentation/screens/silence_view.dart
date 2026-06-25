import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../bloc/silence_bloc.dart';
import '../../../../core/repositories/database_repository.dart';

class SilenceView extends StatefulWidget {
  const SilenceView({super.key});

  @override
  State<SilenceView> createState() => _SilenceViewState();
}

class _SilenceViewState extends State<SilenceView> {
  late SilenceBloc _silenceBloc;

  @override
  void initState() {
    super.initState();
    try {
      final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
      final mindState = dbRepo.currentMindState;
      if (mindState == 'burnout_state') {
        BlocProvider.of<SilenceBloc>(context).add(const ChangeDurationRequested(20));
      } else if (mindState == 'overthinking_state') {
        BlocProvider.of<SilenceBloc>(context).add(const ChangeDurationRequested(5));
      }
    } catch (e) {
      // Silent catch if repository is not found (e.g. in widget testing environment without provider setup)
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _silenceBloc = BlocProvider.of<SilenceBloc>(context);
  }

  @override
  void dispose() {
    _silenceBloc.add(ResetTimerRequested());
    super.dispose();
  }

  final List<Map<String, String>> _zenReadings = [
    {
      'title': 'Buông bỏ ngoại cảnh',
      'content': 'Trút bỏ bớt gánh nặng. Những gì thuộc về ngoài kia, hãy để chúng tự nhiên diễn ra. Lúc này, bạn chỉ cần chịu trách nhiệm cho hơi thở và sự bình yên của chính mình.',
    },
    {
      'title': 'Neo giữ hơi thở',
      'content': 'Hơi thở là điểm tựa tự nhiên nhất của bạn. Không cần cố gắng điều chỉnh nhịp thở nhanh hay chậm. Chỉ cần cảm nhận luồng khí nhẹ nhàng đi vào, đi ra và nhận biết cơ thể đang sống.',
    },
    {
      'title': 'An trú hiện tại',
      'content': 'Quá khứ đã qua, tương lai chưa tới. Khoảnh khắc này là thực tại duy nhất bạn có. Hãy cho phép bản thân tạm dừng mọi lo toan, chỉ tồn tại trọn vẹn trong khoảng lặng này.',
    },
  ];
  int _currentReadingIndex = 0;

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: ZenTheme.slateMedium,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            "Khoảng lặng lắng dịu",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Lora', color: ZenTheme.creamWhite),
          ),
          content: const Text(
            "Cảm ơn bạn đã dành thời gian ngồi yên. Mong sự bình lặng và nhẹ nhõm này sẽ tiếp tục đồng hành cùng bạn.",
            textAlign: TextAlign.center,
            style: TextStyle(color: ZenTheme.softGray, height: 1.45),
          ),
          actions: [
            Center(
              child: ZenButton(
                text: "Đón nhận",
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  BlocProvider.of<SilenceBloc>(context).add(ResetTimerRequested());
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSoundSelectorSheet(BuildContext context, SilenceState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: ZenTheme.slateMedium,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Chọn nhạc nền định tâm",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontFamily: 'Lora',
                          fontSize: 18,
                          color: ZenTheme.creamWhite,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...[
                    {
                      'name': 'Mưa Rơi',
                      'icon': Icons.water_drop,
                      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      'desc': 'Tiếng mưa rơi nhẹ nhàng gột rửa tâm trí',
                    },
                    {
                      'name': 'Tiếng Sóng',
                      'icon': Icons.waves,
                      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
                      'desc': 'Sóng biển rì rào đưa tâm hồn về bến lặng',
                    },
                    {
                      'name': 'Chuông Thiền',
                      'icon': Icons.spa,
                      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
                      'desc': 'Chuông đồng ngân vang thanh lọc mọi xao động',
                    },
                  ].map((sound) {
                    final isSelected = state.currentSound == sound['name'];
                    final soundName = sound['name'] as String;
                    final soundUrl = sound['url'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ZenTheme.sageGreen.withValues(alpha: 0.12)
                            : ZenTheme.creamWhite.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? ZenTheme.sageGreen.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Icon(
                          sound['icon'] as IconData,
                          color: isSelected ? ZenTheme.sageGreen : ZenTheme.softGray,
                        ),
                        title: Text(
                          soundName,
                          style: TextStyle(
                            color: isSelected ? ZenTheme.creamWhite : ZenTheme.creamWhite.withValues(alpha: 0.8),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          sound['desc'] as String,
                          style: TextStyle(
                            color: ZenTheme.softGray.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: ZenTheme.sageGreen)
                            : null,
                        onTap: () {
                          BlocProvider.of<SilenceBloc>(context).add(
                            SelectSoundRequested(soundName: soundName, soundUrl: soundUrl),
                          );
                          Navigator.pop(sheetCtx);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ZenTheme.creamWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Khoảng lặng",
          style: textTheme.titleLarge!.copyWith(fontFamily: 'Lora', fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền xanh nước biển thâm trầm
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZenTheme.slateDark, Color(0xff0b1016)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: BlocConsumer<SilenceBloc, SilenceState>(
              listener: (context, state) {
                if (state.isCompleted) {
                  _showCompletionDialog();
                }
              },
              builder: (context, state) {
                final double progress = state.secondsRemaining / (state.selectedDurationMinutes * 60);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gợi ý tư thế ban đầu
                      IgnorePointer(
                        ignoring: state.isTimerRunning,
                        child: AnimatedOpacity(
                          opacity: state.isTimerRunning ? 0.0 : 0.8,
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              "Hãy ngồi thoải mái, thả lỏng vai và khép hờ mắt...",
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium!.copyWith(
                                color: ZenTheme.softGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 1. Đồng hồ đếm ngược
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<SilenceBloc>(context).add(ToggleTimerRequested());
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  backgroundColor: ZenTheme.creamWhite.withValues(alpha: 0.04),
                                  valueColor: const AlwaysStoppedAnimation<Color>(ZenTheme.sageGreen),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatDuration(state.secondsRemaining),
                                    style: textTheme.displayLarge!.copyWith(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w200,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.isTimerRunning ? "Lắng yên..." : "Nhấn để bắt đầu",
                                    style: textTheme.bodyMedium!.copyWith(
                                      color: state.isTimerRunning ? ZenTheme.sageGreen : ZenTheme.softGray,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Icon(
                                    state.isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                    color: ZenTheme.sageGreen,
                                    size: 36,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [5, 10, 15, 20].map((minutes) {
                          final isSelected = state.selectedDurationMinutes == minutes;
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<SilenceBloc>(context).add(ChangeDurationRequested(minutes));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? ZenTheme.sageGreen.withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? ZenTheme.sageGreen.withValues(alpha: 0.2) : ZenTheme.creamWhite.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Text(
                                "$minutes phút",
                                style: TextStyle(
                                  color: isSelected ? ZenTheme.sageGreen : ZenTheme.softGray,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 2. Nhạc nền
                      GestureDetector(
                        onTap: () => _showSoundSelectorSheet(context, state),
                        behavior: HitTestBehavior.opaque,
                        child: GlassContainer(
                          opacity: 0.05,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ZenTheme.inkBlue.withValues(alpha: 0.08),
                                    ),
                                    child: const Icon(Icons.music_note, color: ZenTheme.inkBlue, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nhạc nền định tâm", style: textTheme.titleLarge!.copyWith(fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text("Âm thanh: ${state.currentSound}", style: textTheme.bodyMedium!.copyWith(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  state.isPlayingSound ? Icons.volume_up : Icons.volume_off,
                                  color: state.isPlayingSound ? ZenTheme.sageGreen : ZenTheme.softGray,
                                  size: 26,
                                ),
                                onPressed: () {
                                  BlocProvider.of<SilenceBloc>(context).add(ToggleSoundRequested());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
 
                      // 3. Sách thiền định
                      _buildZenReading(textTheme),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZenReading(TextTheme textTheme) {
    final reading = _zenReadings[_currentReadingIndex];

    return GlassContainer(
      opacity: 0.05,
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reading['title']!,
                style: textTheme.titleLarge!.copyWith(fontSize: 16, color: ZenTheme.softGold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: ZenTheme.softGray, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentReadingIndex =
                            (_currentReadingIndex - 1 + _zenReadings.length) % _zenReadings.length;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: ZenTheme.softGray, size: 20),
                    onPressed: () {
                      setState(() {
                        _currentReadingIndex = (_currentReadingIndex + 1) % _zenReadings.length;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reading['content']!,
            style: textTheme.bodyLarge!.copyWith(
              fontSize: 13,
              height: 1.6,
              color: ZenTheme.creamWhite.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
