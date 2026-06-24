import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/mind_garden_bloc.dart';
import '../../../daily_anchor/data/models/anchor_model.dart';
import '../widgets/zen_garden_painter.dart';

class MindGardenScreen extends StatefulWidget {
  const MindGardenScreen({super.key});

  @override
  State<MindGardenScreen> createState() => _MindGardenScreenState();
}

class _MindGardenScreenState extends State<MindGardenScreen> {
  late DateTime _currentMonth;
  bool _isCalendarView = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadGardenData();
  }

  void _loadGardenData() {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is Authenticated) {
      BlocProvider.of<MindGardenBloc>(
        context,
      ).add(LoadGardenRequested(uid: authState.user.uid, month: _currentMonth));
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + offset,
        1,
      );
    });
    _loadGardenData();
  }

  int _getDaysInMonth(DateTime dt) {
    return DateTime(dt.year, dt.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: ZenTheme.creamWhite, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: GlassContainer(
          opacity: 0.08,
          radius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                  color: ZenTheme.creamWhite,
                  size: 22,
                ),
                onPressed: () => _changeMonth(-1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Text(
                "Tháng ${_currentMonth.month.toString().padLeft(2, '0')} / ${_currentMonth.year}",
                style: textTheme.titleMedium!.copyWith(
                  fontFamily: 'Lora',
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: ZenTheme.creamWhite,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  color: ZenTheme.creamWhite,
                  size: 22,
                ),
                onPressed: () => _changeMonth(1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: ZenTheme.creamWhite,
              size: 20,
            ),
            tooltip: "Giải nghĩa khu vườn",
            onPressed: () => _showExplanationDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Nền Zen tối sâu lắng
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZenTheme.slateDark, Color(0xff0b0e11)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // 1. Bộ chuyển đổi chế độ xem (Vườn Tâm Trí vs Lịch Tháng)
                _buildViewToggler(),

                const SizedBox(height: 12),

                // 2. Lời dẫn dắt tự thấu hiểu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Khu vườn này là không gian an toàn phản chiếu những dấu chân cảm xúc của bạn. Không có đúng sai hay áp lực, chỉ có sự tĩnh lặng của hiện tại. Nhấn vào một vị trí để xem lại chiêm nghiệm của mình.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: ZenTheme.softGray.withOpacity(0.7),
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. Canvas vẽ Khu Vườn
                Expanded(
                  child: BlocBuilder<MindGardenBloc, MindGardenState>(
                    builder: (context, state) {
                      if (state is MindGardenLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ZenTheme.sageGreen,
                          ),
                        );
                      }

                      if (state is MindGardenSuccess) {
                        final daysCount = _getDaysInMonth(state.displayMonth);
                        final dayAnchorsMap = {
                          for (var a in state.anchors)
                            int.parse(a.date.split('-')[2]): a,
                        };

                        if (_isCalendarView) {
                          return Center(
                            child: SingleChildScrollView(
                              child: _buildCalendarGridView(
                                daysCount,
                                dayAnchorsMap,
                              ),
                            ),
                          );
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final size =
                                min(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ) *
                                0.95;

                            return Center(
                              child: GestureDetector(
                                onTapDown: (details) => _handleCanvasTap(
                                  details.localPosition,
                                  Size(size, size),
                                  daysCount,
                                  dayAnchorsMap,
                                ),
                                child: Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    color: ZenTheme.creamWhite.withOpacity(
                                      0.02,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ZenTheme.creamWhite.withOpacity(
                                        0.04,
                                      ),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: CustomPaint(
                                    size: Size(size, size),
                                    painter: ZenGardenPainter(
                                      dayAnchors: dayAnchorsMap,
                                      daysInMonth: daysCount,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      if (state is MindGardenFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              state.errorMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: ZenTheme.mistRed),
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Tâm trí tổng quan & Bảng chú giải chú thích Zen
                BlocBuilder<MindGardenBloc, MindGardenState>(
                  builder: (context, state) {
                    if (state is MindGardenSuccess) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInsightCard(state.anchors),
                          const SizedBox(height: 12),
                          _buildLegendRow(),
                        ],
                      );
                    }
                    return _buildLegendRow();
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(List<AnchorModel> anchors) {
    final completed = anchors.where((a) => a.eveningCompleted).toList();
    if (completed.isEmpty) {
      return const SizedBox.shrink();
    }

    int peaceful = 0;
    int grateful = 0;
    int burnout = 0;
    int overthinking = 0;
    int lonely = 0;

    for (final a in completed) {
      final e = a.eveningEmotion;
      if (e == 'peaceful')
        peaceful++;
      else if (e == 'grateful')
        grateful++;
      else if (e == 'burnout')
        burnout++;
      else if (e == 'overthinking')
        overthinking++;
      else if (e == 'lonely' || e == 'empty')
        lonely++;
    }

    String title = "Góc tự thấu hiểu";
    String message =
        "Mỗi viên sỏi và bông hoa trong vườn đều là những bước chân cảm xúc chân thực của bạn. Hãy tiếp tục vun vén khu vườn nội tâm mỗi ngày.";
    IconData icon = Icons.spa_outlined;
    Color iconColor = ZenTheme.sageGreen;

    final positive = peaceful + grateful;
    final stress = burnout + overthinking;

    if (positive > stress && positive >= lonely) {
      title = "Khu vườn an yên";
      message =
          "Tháng này vườn của bạn ngập tràn sự bình yên và lòng biết ơn. Tâm trí bạn đang dần hình thành sự hài hòa và kết nối sâu sắc.";
      icon = Icons.local_florist_outlined;
      iconColor = ZenTheme.sageGreen;
    } else if (stress >= positive && stress >= lonely) {
      title = "Sóng cát động hỏa";
      message =
          "Khu vườn phản chiếu những phiến đá kiệt sức đỏ trầm và sóng cát nhiều suy nghĩ. Bạn đang trải qua giai đoạn bận rộn, hãy cho phép mình được nghỉ ngơi nhiều hơn.";
      icon = Icons.wb_twilight_outlined;
      iconColor = ZenTheme.mistRed;
    } else if (lonely > positive && lonely > stress) {
      title = "Khoảng lặng tĩnh mịch";
      message =
          "Những lối đi sỏi cô đơn đang nối dài trong vườn. Đây có thể là khoảng lặng chiêm nghiệm sâu sắc, hãy ôm lấy sự tĩnh lặng của chính mình.";
      icon = Icons.nights_stay_outlined;
      iconColor = ZenTheme.softGray;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassContainer(
        opacity: 0.06,
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ZenTheme.creamWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: ZenTheme.softGray.withOpacity(0.85),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassContainer(
        opacity: 0.04,
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildLegendItem("Bình yên", "peaceful"),
            _buildLegendItem("Biết ơn", "grateful"),
            _buildLegendItem("Kiệt sức", "burnout"),
            _buildLegendItem("Nghĩ nhiều", "overthinking"),
            _buildLegendItem("Cô đơn", "lonely"),
            _buildLegendItem("Nửa ngày", "clay"),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String emotion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZenLegendIcon(
          emotion: emotion,
          size: emotion == 'clay' ? const Size(15, 15) : const Size(18, 18),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: ZenTheme.softGray.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassContainer(
                opacity: 0.12,
                radius: 28,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.spa_outlined,
                          color: ZenTheme.sageGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Giải nghĩa Vườn Tâm Trí",
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    _buildHelpItem(
                      "Xoắn ốc thời gian",
                      "Các ngày trong tháng xếp theo hình xoắn ốc Fibonacci từ tâm (ngày 1) lan dần ra ngoài, đại diện cho dòng chảy cuộc sống sinh trưởng tự nhiên.",
                    ),
                    const SizedBox(height: 14),
                    _buildHelpItem(
                      "Dấu ấn cảm xúc",
                      "Mỗi trạng thái cảm xúc bạn ghi nhận cuối ngày sẽ được đại diện bằng biểu tượng đặc trưng (như ☀️ cho bình yên, 🔥 cho kiệt sức, 🌸 cho biết ơn) đặt trên vòng xoắn ốc.",
                    ),
                    const SizedBox(height: 14),
                    _buildHelpItem(
                      "Thiết kế không áp lực",
                      "Những ngày bỏ trống không phải là thiếu sót, đó là khoảng trống bình yên để bạn nghỉ ngơi không phán xét.",
                    ),
                    const SizedBox(height: 24),
                    ZenButton(
                      text: "Đã hiểu",
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ZenTheme.softGold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: ZenTheme.softGray.withOpacity(0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggler() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isCalendarView = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: !_isCalendarView
                    ? ZenTheme.creamWhite.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Vườn tâm trí",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: !_isCalendarView
                      ? ZenTheme.creamWhite
                      : ZenTheme.softGray,
                  fontWeight: !_isCalendarView
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isCalendarView = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isCalendarView
                    ? ZenTheme.creamWhite.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Lịch tháng",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: _isCalendarView
                      ? ZenTheme.creamWhite
                      : ZenTheme.softGray,
                  fontWeight: _isCalendarView
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGridView(
    int daysCount,
    Map<int, AnchorModel> dayAnchorsMap,
  ) {
    final startWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday;
    final emptyCells = startWeekday - 1;
    final totalCells = emptyCells + daysCount;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 7 + totalCells,
      itemBuilder: (context, index) {
        if (index < 7) {
          final days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
          return Center(
            child: Text(
              days[index],
              style: GoogleFonts.nunito(
                color: ZenTheme.softGray.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          );
        }

        final cellIndex = index - 7;
        if (cellIndex < emptyCells) {
          return const SizedBox.shrink();
        }

        final day = cellIndex - emptyCells + 1;
        final anchor = dayAnchorsMap[day];

        final hasData = anchor != null && anchor.morningCompleted;
        final completed = anchor != null && anchor.eveningCompleted;
        final emotion = anchor?.eveningEmotion;

        Color cellBg = Colors.transparent;
        Color borderCol = ZenTheme.creamWhite.withOpacity(0.04);
        Widget? iconWidget;

        if (hasData) {
          if (!completed) {
            cellBg = ZenTheme.softGold.withOpacity(0.06);
            borderCol = ZenTheme.softGold.withOpacity(0.2);
            iconWidget = const ZenLegendIcon(
              emotion: 'clay',
              size: Size(16, 16),
            );
          } else {
            final color = _getEmotionColor(emotion);
            cellBg = color.withOpacity(0.08);
            borderCol = color.withOpacity(0.3);
            iconWidget = ZenLegendIcon(
              emotion: emotion!,
              size: const Size(16, 16),
            );
          }
        }

        return GestureDetector(
          onTap: () {
            if (hasData) {
              HapticFeedback.lightImpact();
              _showReflectionBottomSheet(context, anchor, day);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: cellBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderCol, width: 1.0),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4,
                  left: 6,
                  child: Text(
                    '$day',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      color: hasData
                          ? ZenTheme.creamWhite
                          : ZenTheme.softGray.withOpacity(0.4),
                      fontWeight: hasData ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (iconWidget != null)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: iconWidget,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCanvasTap(
    Offset localPosition,
    Size size,
    int daysCount,
    Map<int, AnchorModel> dayAnchors,
  ) {
    // Quét tọa độ của 31 ngày xem có ngày nào khớp với điểm chạm không
    for (int d = 1; d <= daysCount; d++) {
      final pos = ZenGardenPainter.getDayOffset(d, daysCount, size);
      final distance = (localPosition - pos).distance;

      // Hitbox thoải mái: bán kính click 20px
      if (distance <= 20.0) {
        final anchor = dayAnchors[d];
        if (anchor != null && anchor.morningCompleted) {
          HapticFeedback.lightImpact();
          _showReflectionBottomSheet(context, anchor, d);
        }
        break;
      }
    }
  }

  void _showReflectionBottomSheet(
    BuildContext context,
    AnchorModel anchor,
    int day,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        final emotionText = _getEmotionLabel(anchor.eveningEmotion);
        final emotionColor = _getEmotionColor(anchor.eveningEmotion);

        return GlassContainer(
          opacity: 0.12,
          radius: 32,
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tiêu đề Bottom Sheet
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ngày $day tháng ${_currentMonth.month}",
                    style: GoogleFonts.lora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ZenTheme.creamWhite,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: emotionColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: emotionColor.withOpacity(0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      emotionText,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: emotionColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              // 1. Ý định ngày mới
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.brightness_5_outlined,
                    color: ZenTheme.sageGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ý định ngày mới",
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: ZenTheme.softGray.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\"${anchor.intention}\"",
                          style: GoogleFonts.lora(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Nhật ký tối (nếu có)
              if (anchor.eveningCompleted &&
                  anchor.eveningNote != null &&
                  anchor.eveningNote!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.nightlight_round_outlined,
                      color: ZenTheme.inkBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nhìn lại buổi tối",
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: ZenTheme.softGray.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            anchor.eveningNote!,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: ZenTheme.creamWhite.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // 3. Chiêm nghiệm trong ngày
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.spa_outlined,
                    color: ZenTheme.softGold,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gợi ý chiêm nghiệm mang theo",
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: ZenTheme.softGray.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          anchor.affirmationText,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: ZenTheme.softGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              ZenButton(text: "Đóng", onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }

  String _getEmotionLabel(String? emotion) {
    if (emotion == null) return "Chưa nhìn lại";
    switch (emotion) {
      case 'burnout':
        return "Kiệt sức 🔥";
      case 'overthinking':
        return "Nhiều suy nghĩ 🌀";
      case 'lonely':
        return "Cô đơn 🌑";
      case 'empty':
        return "Trống rỗng 🫧";
      case 'peaceful':
        return "Bình yên ☀️";
      case 'grateful':
        return "Biết ơn 🌸";
      default:
        return "Bình thường";
    }
  }

  Color _getEmotionColor(String? emotion) {
    if (emotion == null) return ZenTheme.softGray.withOpacity(0.6);
    switch (emotion) {
      case 'burnout':
        return ZenTheme.mistRed;
      case 'overthinking':
        return ZenTheme.inkBlue;
      case 'lonely':
        return ZenTheme.softGray;
      case 'empty':
        return ZenTheme.creamWhite;
      case 'peaceful':
        return ZenTheme.sageGreen;
      case 'grateful':
        return ZenTheme.softGold;
      default:
        return ZenTheme.softGray;
    }
  }
}

class ZenLegendIcon extends StatelessWidget {
  final String emotion;
  final Size size;

  const ZenLegendIcon({
    super.key,
    required this.emotion,
    this.size = const Size(20, 20),
  });

  @override
  Widget build(BuildContext context) {
    String emoji = "";
    switch (emotion) {
      case 'peaceful':
        emoji = "☀️";
        break;
      case 'grateful':
        emoji = "🌸";
        break;
      case 'burnout':
        emoji = "🔥";
        break;
      case 'overthinking':
        emoji = "🌀";
        break;
      case 'lonely':
        emoji = "🌑";
        break;
      case 'empty':
        emoji = "🫧";
        break;
      case 'clay':
        emoji = "🌅";
        break;
      default:
        emoji = "⚪";
        break;
    }
    return Text(
      emoji,
      style: TextStyle(fontSize: size.width),
    );
  }
}
