import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/zen_button.dart';

enum MicroRitualType { water, breathing, shoulder }

class MicroRitualSheet extends StatefulWidget {
  final MicroRitualType type;

  const MicroRitualSheet({super.key, required this.type});

  static void show(BuildContext context, MicroRitualType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => MicroRitualSheet(type: type),
    );
  }

  @override
  State<MicroRitualSheet> createState() => _MicroRitualSheetState();
}

class _MicroRitualSheetState extends State<MicroRitualSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _breatheAnim;

  int _breathingCount = 0;
  final int _targetBreaths = 5;
  bool _isExhaling = false;

  @override
  void initState() {
    super.initState();
    // 8 giây một chu kỳ hơi thở: 4s hít vào, 4s thở ra
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _breatheAnim = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    if (widget.type == MicroRitualType.breathing) {
      _startBreathingCycle();
    }
  }

  void _startBreathingCycle() {
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isExhaling = true);
        HapticFeedback.lightImpact();
        _animController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        if (!mounted) return;
        setState(() {
          _isExhaling = false;
          _breathingCount++;
        });
        HapticFeedback.mediumImpact();
        if (_breathingCount < _targetBreaths) {
          _animController.forward();
        }
      }
    });
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.glassBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 14, 24, 24 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo nhẹ ở đỉnh sheet
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nội dung tương tác theo từng loại ritual
              if (widget.type == MicroRitualType.breathing)
                _buildBreathingBody()
              else if (widget.type == MicroRitualType.water)
                _buildWaterBody()
              else
                _buildShoulderBody(),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. RITUAL: 5 HƠI THỞ SÂU (INTERACTIVE BREATHING CIRCLE) ---
  Widget _buildBreathingBody() {
    final isDone = _breathingCount >= _targetBreaths;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "5 HƠI THỞ SÂU",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isDone ? "Tâm trí đã lắng dịu" : (_isExhaling ? "Thở ra thật êm ái..." : "Hít vào thật nhẹ nhàng..."),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 28),

        // Vòng tròn hơi thở tương tác
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vòng hào quang phập phồng
              ScaleTransition(
                scale: _breatheAnim,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.28),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Vòng kính trung tâm
              ScaleTransition(
                scale: _breatheAnim,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 26,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.air_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Các hạt định lượng tiến độ (5 nốt hạt)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_targetBreaths, (idx) {
            final active = idx < _breathingCount;
            final current = idx == _breathingCount && !isDone;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: current ? 20 : 9,
              height: 9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: active || current
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                border: Border.all(
                  color: active || current
                      ? AppColors.primaryLight
                      : AppColors.glassBorder,
                  width: 1,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          isDone ? "Bạn đã hoàn thành 5 nhịp thở cân bằng" : "Nhịp thở ${_breathingCount + 1} / $_targetBreaths",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),

        ZenButton(
          text: isDone ? "Khép lại trong bình yên" : "Dừng lại lúc này",
          isSecondary: !isDone,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // --- 2. RITUAL: UỐNG NƯỚC CHÁNH NIỆM ---
  Widget _buildWaterBody() {
    final steps = [
      {
        'num': '1',
        'title': 'Rót một ngụm nước ấm',
        'desc': 'Cảm nhận hơi ấm truyền qua thành cốc và ngón tay bạn.',
      },
      {
        'num': '2',
        'title': 'Uống từng ngụm thật chậm',
        'desc': 'Đừng vội nuốt. Cảm nhận dòng nước tưới mát vòm họng và cổ.',
      },
      {
        'num': '3',
        'title': 'Ghi nhận sự sống',
        'desc': 'Cảm ơn cơ thể kỳ diệu vẫn luôn duy trì nhịp đập mỗi giây.',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "UỐNG NƯỚC CHÁNH NIỆM",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Nuôi dưỡng từng tế bào",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Các bước thực hành
        ...steps.map((s) => _buildStepCard(s['num']!, s['title']!, s['desc']!)),

        const SizedBox(height: 20),
        ZenButton(
          text: "Tôi đã uống xong • Cảm thấy tươi tỉnh",
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // --- 3. RITUAL: THẢ LỎNG VAI & CỔ ---
  Widget _buildShoulderBody() {
    final steps = [
      {
        'num': '1',
        'title': 'Nhấc cao đôi vai',
        'desc': 'Hít một hơi sâu và kéo hai vai lên sát tai, giữ căng trong 3 giây.',
      },
      {
        'num': '2',
        'title': 'Buông rơi tự do',
        'desc': 'Thở mạnh ra bằng miệng và để trọng lực kéo toàn bộ vai rũ xuống.',
      },
      {
        'num': '3',
        'title': 'Xoay tròn êm dịu',
        'desc': 'Xoay nhẹ khớp vai ra sau 3 vòng để giải tỏa toàn bộ gánh nặng.',
      },
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "THẢ LỎNG VAI & CỔ",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Trút bỏ mọi gánh nặng",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Các bước thực hành
        ...steps.map((s) => _buildStepCard(s['num']!, s['title']!, s['desc']!)),

        const SizedBox(height: 20),
        ZenButton(
          text: "Tôi đã buông lỏng • Đôi vai nhẹ nhõm",
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildStepCard(String number, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
