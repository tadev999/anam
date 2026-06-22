import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../bloc/monastery_bloc.dart';

class MonasteryView extends StatefulWidget {
  const MonasteryView({super.key});

  @override
  State<MonasteryView> createState() => _MonasteryViewState();
}

class _MonasteryViewState extends State<MonasteryView> {
  final List<Map<String, String>> _zenReadings = [
    {
      'title': 'Chủ nghĩa Khắc Kỷ Stoic',
      'content': 'Tập trung hoàn toàn vào những gì bạn có thể kiểm soát. Suy nghĩ của bạn, hành vi của bạn, mong muốn của bạn. Những gì xảy ra bên ngoài — thời tiết, thái độ của người khác, biến cố xã hội — đều nằm ngoài tầm tay. Hãy chấp nhận chúng với sự bình thản tối đa (Amor Fati).',
    },
    {
      'title': 'Hơi thở Chánh niệm',
      'content': 'Hãy chú ý đến từng luồng khí đi vào và đi ra qua hai cánh mũi. Khi hít vào, biết mình đang hít vào. Khi thở ra, biết mình đang thở ra. Khi tâm trí đi lang thang, nhẹ nhàng mang nó trở lại với hơi thở mà không phán xét, ghét bỏ.',
    },
    {
      'title': 'Sức mạnh của Hiện tại',
      'content': 'Quá khứ đã trôi qua, tương lai thì chưa tới. Mọi lo âu đều sinh ra từ việc nuối tiếc quá khứ hoặc sợ hãi tương lai. Chỉ có giây phút hiện tại này là thực sự thuộc về bạn. Hãy trân trọng và sống trọn vẹn trong giây phút này.',
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
            "Kết Thúc Thiền Định",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Lora', color: ZenTheme.creamWhite),
          ),
          content: const Text(
            "Chúc mừng bạn đã hoàn thành phiên thiền định chánh niệm. Tâm trí bạn giờ đây đã sạch sẽ và bình yên hơn.",
            textAlign: TextAlign.center,
            style: TextStyle(color: ZenTheme.softGray),
          ),
          actions: [
            Center(
              child: ZenButton(
                text: "Xác nhận",
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  BlocProvider.of<MonasteryBloc>(context).add(ResetTimerRequested());
                },
              ),
            ),
          ],
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
          "Chế Độ Tu Viện",
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
            child: BlocConsumer<MonasteryBloc, MonasteryState>(
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
                      // 1. Đồng hồ đếm ngược
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: ZenTheme.creamWhite.withOpacity(0.04),
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
                                  state.isTimerRunning ? "Đang thiền định..." : "Nhấn để bắt đầu",
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: state.isTimerRunning ? ZenTheme.sageGreen : ZenTheme.softGray,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                IconButton(
                                  icon: Icon(
                                    state.isTimerRunning ? Icons.pause_circle_outline : Icons.play_circle_outline,
                                    color: ZenTheme.sageGreen,
                                    size: 36,
                                  ),
                                  onPressed: () {
                                    BlocProvider.of<MonasteryBloc>(context).add(ToggleTimerRequested());
                                  },
                                ),
                              ],
                            ),
                          ],
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
                              BlocProvider.of<MonasteryBloc>(context).add(ChangeDurationRequested(minutes));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? ZenTheme.sageGreen.withOpacity(0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? ZenTheme.sageGreen.withOpacity(0.2) : ZenTheme.creamWhite.withOpacity(0.05),
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
                      GlassContainer(
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
                                    color: ZenTheme.inkBlue.withOpacity(0.08),
                                  ),
                                  child: const Icon(Icons.music_note, color: ZenTheme.inkBlue, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Nhạc nền chánh niệm", style: textTheme.titleLarge!.copyWith(fontSize: 15)),
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
                                BlocProvider.of<MonasteryBloc>(context).add(ToggleSoundRequested());
                              },
                            ),
                          ],
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
              color: ZenTheme.creamWhite.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
