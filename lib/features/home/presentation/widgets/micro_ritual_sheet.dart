import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/zen_button.dart';

enum MicroRitualType {
  water,
  breathing,
  shoulder,
  sunlight,
  stretch,
  restEyes,
  sigh,
  handWarmth,
  gratitudeChest,
  tidySpace,
  readPages,
  fiveMinRule,
  kindMessage,
  walkUnplugged,
  threeGratitudes,
  showerCleanse,
}

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
        if (!mounted) return;
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
              _buildRitualContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRitualContent() {
    switch (widget.type) {
      case MicroRitualType.breathing:
        return _buildBreathingBody();
      case MicroRitualType.water:
        return _buildWaterBody();
      case MicroRitualType.shoulder:
        return _buildShoulderBody();
      case MicroRitualType.sunlight:
        return _buildSunlightBody();
      case MicroRitualType.stretch:
        return _buildStretchBody();
      case MicroRitualType.restEyes:
        return _buildRestEyesBody();
      case MicroRitualType.sigh:
        return _buildSighBody();
      case MicroRitualType.handWarmth:
        return _buildHandWarmthBody();
      case MicroRitualType.gratitudeChest:
        return _buildGratitudeChestBody();
      case MicroRitualType.tidySpace:
        return _buildTidySpaceBody();
      case MicroRitualType.readPages:
        return _buildReadPagesBody();
      case MicroRitualType.fiveMinRule:
        return _buildFiveMinRuleBody();
      case MicroRitualType.kindMessage:
        return _buildKindMessageBody();
      case MicroRitualType.walkUnplugged:
        return _buildWalkUnpluggedBody();
      case MicroRitualType.threeGratitudes:
        return _buildThreeGratitudesBody();
      case MicroRitualType.showerCleanse:
        return _buildShowerCleanseBody();
    }
  }

  // --- 1. RITUAL: 5 HƠI THỞ SÂU (Bài 71) ---
  Widget _buildBreathingBody() {
    final isDone = _breathingCount >= _targetBreaths;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "5 HƠI THỞ ĐỊNH TÂM",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isDone
              ? "Tâm trí đã lắng dịu"
              : (_isExhaling
                  ? "Thở ra thật êm ái..."
                  : "Hít vào thật nhẹ nhàng..."),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Triết lý Mạch 3 / Bài 71
        _buildBookQuoteBadge(
          "Bài 71: Hơi Thở",
          "Thở — điều duy nhất bạn đã làm đúng từ giây đầu tiên và không bao giờ được nhớ đến.",
          AppColors.primary,
        ),
        const SizedBox(height: 16),

        // Vòng tròn hơi thở tương tác
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: _breatheAnim,
                child: Container(
                  width: 140,
                  height: 140,
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
              ScaleTransition(
                scale: _breatheAnim,
                child: Container(
                  width: 98,
                  height: 98,
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
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check_rounded : Icons.air_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5 hạt định lượng tiến độ
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
          isDone
              ? "Bạn đã hoàn thành 5 nhịp thở cân bằng"
              : "Nhịp thở ${_breathingCount + 1} / $_targetBreaths",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

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

  // --- 2. RITUAL: UỐNG NƯỚC CHÁNH NIỆM (Bài 65) ---
  Widget _buildWaterBody() {
    return _buildGuidedPebbleBody(
      badge: "UỐNG NƯỚC TRONG IM LẶNG",
      title: "Nuôi dưỡng từng tế bào",
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFF38BDF8),
      bookArticle: "Bài 65: Ly Nước",
      bookQuote: "Uống một ly nước trong im lặng — và nhận ra bạn đang ở đây, trong khoảnh khắc này.",
      steps: const [
        {
          'num': '1',
          'title': 'Rót một ngụm nước ấm',
          'desc': 'Cảm nhận hơi ấm truyền qua thành cốc và ngón tay bạn.',
        },
        {
          'num': '2',
          'title': 'Uống chậm không làm gì khác',
          'desc': 'Không nhìn màn hình. Cảm nhận dòng nước tưới mát vòm họng và ngực.',
        },
        {
          'num': '3',
          'title': 'Ghi nhận sự sống',
          'desc': 'Cảm ơn cơ thể kỳ diệu vẫn luôn duy trì nhịp đập mỗi giây.',
        },
      ],
      buttonText: "Tôi đã uống xong • Cơ thể tươi mới",
    );
  }

  // --- 3. RITUAL: ĐÓN NẮNG SỚM (Y sinh học Serotonin) ---
  Widget _buildSunlightBody() {
    return _buildGuidedPebbleBody(
      badge: "ĐÓN NẮNG SINH HỌC",
      title: "Kích hoạt nguồn năng lượng",
      icon: Icons.wb_sunny_rounded,
      accentColor: AppColors.secondary,
      bookArticle: "Nhịp Sinh Học Nội Sinh",
      bookQuote: "Ánh sáng ban mai báo hiệu cho từng thụ thể ipRGCs ở đáy mắt: Ngày mới an lành bắt đầu.",
      steps: const [
        {
          'num': '1',
          'title': 'Tìm ánh sáng tự nhiên',
          'desc': 'Bước ra ban công, cửa sổ hoặc khoảng sân có ánh sáng ban mai.',
        },
        {
          'num': '2',
          'title': 'Đón nhận dịu dàng',
          'desc': 'Khép nhẹ mi mắt, để tia nắng sớm sưởi ấm gương mặt 2 - 3 phút.',
        },
        {
          'num': '3',
          'title': 'Kích hoạt Serotonin',
          'desc': 'Đồng hồ sinh học được thiết lập lại, đánh thức sinh khí toàn thân.',
        },
      ],
      buttonText: "Tôi đã đón nắng • Tràn đầy sinh khí",
    );
  }

  // --- 4. RITUAL: VƯƠN VAI MỞ NGỰC (Bài 82) ---
  Widget _buildStretchBody() {
    return _buildGuidedPebbleBody(
      badge: "VƯƠN VAI MỞ NGỰC",
      title: "Đón dưỡng khí vào lồng ngực",
      icon: Icons.self_improvement_rounded,
      accentColor: AppColors.primaryLight,
      bookArticle: "Bài 82: Giãn Cơ",
      bookQuote: "Cơ thể bạn đã mang theo căng thẳng này bao lâu rồi mà không được nhớ đến?",
      steps: const [
        {
          'num': '1',
          'title': 'Đan tay ra sau lưng',
          'desc': 'Ngồi hoặc đứng thẳng, đan các ngón tay phía sau và ép nhẹ hai bả vai.',
        },
        {
          'num': '2',
          'title': 'Nâng cằm, hít thật sâu',
          'desc': 'Mở rộng tối đa lồng ngực để dưỡng khí tràn sâu xuống đáy phổi.',
        },
        {
          'num': '3',
          'title': 'Thở ra & thả lỏng',
          'desc': 'Thở êm qua miệng, buông tay và xoay nhẹ khớp vai về trạng thái tự nhiên.',
        },
      ],
      buttonText: "Lồng ngực mở rộng • Tâm trí sáng tỏ",
    );
  }

  // --- 5. RITUAL: NGHỈ MẮT 60 GIÂY (Bài 72) ---
  Widget _buildRestEyesBody() {
    return _buildGuidedPebbleBody(
      badge: "NGHỈ MẮT 60 GIÂY",
      title: "Giải phóng áp lực thị giác",
      icon: Icons.visibility_outlined,
      accentColor: const Color(0xFF2DD4BF),
      bookArticle: "Bài 72: Ranh Giới Số",
      bookQuote: "Ranh giới bạn đặt ra không phải kỷ luật khắc nghiệt, mà vì bạn biết mắt mình cần nó.",
      steps: const [
        {
          'num': '1',
          'title': 'Rời khỏi màn hình',
          'desc': 'Tạm gác lại điện thoại và máy tính, ngồi tựa lưng thoải mái.',
        },
        {
          'num': '2',
          'title': 'Nhìn vào khoảng không xa',
          'desc': 'Phóng tầm mắt ra một điểm ngoài cửa sổ cách xa ít nhất 6 mét.',
        },
        {
          'num': '3',
          'title': 'Chớp mắt thật chậm 5 lần',
          'desc': 'Để tuyến lệ tự nhiên tưới mát giác mạc, các cơ quanh mắt được thả lỏng.',
        },
      ],
      buttonText: "Đôi mắt nhẹ nhõm • Tầm nhìn dịu lại",
    );
  }

  // --- 6. RITUAL: THẢ LỎNG VAI & CỔ (Bài 82) ---
  Widget _buildShoulderBody() {
    return _buildGuidedPebbleBody(
      badge: "THẢ LỎNG VAI & CỔ",
      title: "Trút bỏ mọi gánh nặng",
      icon: Icons.accessibility_new_rounded,
      accentColor: AppColors.primary,
      bookArticle: "Bài 82: Giải Phóng Áp Lực",
      bookQuote: "Hai bờ vai là nơi âm thầm gánh mọi áp lực. Hãy cho phép chúng được rũ xuống.",
      steps: const [
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
          'desc': 'Xoay nhẹ khớp vai ra sau 3 vòng để giải tỏa toàn bộ sự căng cứng.',
        },
      ],
      buttonText: "Tôi đã buông lỏng • Đôi vai nhẹ nhõm",
    );
  }

  // --- 7. RITUAL: THỞ DÀI TRÚT BỎ (PHYSIOLOGICAL SIGH) ---
  Widget _buildSighBody() {
    return _buildGuidedPebbleBody(
      badge: "THỞ DÀI SINH LÝ HỌC",
      title: "Hạ Cortisol tức thì",
      icon: Icons.spa_rounded,
      accentColor: const Color(0xFFF59E0B),
      bookArticle: "Bài 71: Nhịp Thở Nội Sinh",
      bookQuote: "Hai nhịp hít ngắn mở bung phế nang, một nhịp thở dài đưa hệ thần kinh về số 0.",
      steps: const [
        {
          'num': '1',
          'title': 'Hít sâu lần thứ nhất',
          'desc': 'Hít một hơi dài qua mũi để làm đầy khoảng 80% dung tích phổi.',
        },
        {
          'num': '2',
          'title': 'Hít thêm một ngụm ngắn',
          'desc': 'Không thở ra vội, hít dứt khoát thêm một nhịp nữa để mở bung các phế nang.',
        },
        {
          'num': '3',
          'title': 'Thở dài chậm qua miệng',
          'desc': 'Thở ra thật dài, êm kèm tiếng thở phào. Lặp lại 3 chu kỳ để thần kinh lắng lại.',
        },
      ],
      buttonText: "Tâm trạng lắng dịu • Hệ thần kinh về số 0",
    );
  }

  // --- 8. RITUAL: XOA ẤM BÀN TAY ÁP LÊN MẮT ---
  Widget _buildHandWarmthBody() {
    return _buildGuidedPebbleBody(
      badge: "HƠI ẤM LÀM DỊU",
      title: "Vỗ về giác quan thị giác",
      icon: Icons.back_hand_outlined,
      accentColor: const Color(0xFFFB923C),
      bookArticle: "Bài 89: Chăm Sóc Bản Thân",
      bookQuote: "Hơi ấm tự thân từ đôi bàn tay là liều thuốc vỗ về êm dịu nhất mà bạn luôn có sẵn.",
      steps: const [
        {
          'num': '1',
          'title': 'Xoa hai lòng bàn tay',
          'desc': 'Chà xát hai bàn tay vào nhau thật nhanh 10-15 giây đến khi ấm nóng ran.',
        },
        {
          'num': '2',
          'title': 'Úp nhẹ lên hốc mắt',
          'desc': 'Khum bàn tay úp lên hai mắt đang nhắm, không tì đè lên con ngươi.',
        },
        {
          'num': '3',
          'title': 'Hấp thụ bóng tối ấm áp',
          'desc': 'Cảm nhận hơi ấm truyền sâu, xoa dịu dây thần kinh sau một ngày mỏi mệt.',
        },
      ],
      buttonText: "Mắt được vỗ về • Sẵn sàng cho giấc ngủ",
    );
  }

  // --- 9. RITUAL: ĐẶT TAY LÊN TIM (Bài 80, 90) ---
  Widget _buildGratitudeChestBody() {
    return _buildGuidedPebbleBody(
      badge: "TỰ TRẮC ẨN & YÊU THƯƠNG",
      title: "Lắng nghe nhịp tim trung kiên",
      icon: Icons.favorite_rounded,
      accentColor: const Color(0xFFF43F5E),
      bookArticle: "Bài 90: Tồn Tại Là Đủ",
      bookQuote: "Bạn đã tồn tại hôm nay — không chỉ tồn tại, mà là đi qua một ngày không hề dễ dàng.",
      steps: const [
        {
          'num': '1',
          'title': 'Đặt bàn tay lên ngực',
          'desc': 'Khép nhẹ mắt, đặt một hoặc hai bàn tay áp vào chính giữa lồng ngực.',
        },
        {
          'num': '2',
          'title': 'Cảm nhận nhịp đập',
          'desc': 'Cảm nhận sự sống đang âm thầm, bền bỉ nuôi dưỡng bạn từng khoảnh khắc.',
        },
        {
          'num': '3',
          'title': 'Thì thầm lời vỗ về',
          'desc': 'Nói với chính mình: "Hôm nay tôi đã nỗ lực hết mình. Lúc này, tôi được bình an."',
        },
      ],
      buttonText: "Tôi ôm lấy chính mình • Bình yên ngập tràn",
    );
  }

  // --- 10. RITUAL MỚI: SẮP XẾP KHÔNG GIAN (Bài 62 & 69) ---
  Widget _buildTidySpaceBody() {
    return _buildGuidedPebbleBody(
      badge: "SẮP XẾP GÓC NHỎ",
      title: "Gọn gàng nơi chốn • An định bên trong",
      icon: Icons.cleaning_services_rounded,
      accentColor: const Color(0xFF10B981),
      bookArticle: "Bài 62: Sắp Xếp Không Gian",
      bookQuote: "Dọn dẹp không phải kỷ luật — đó là lần đầu tiên bạn nói với mình: Tôi xứng đáng bắt đầu từ điều được sắp xếp.",
      steps: const [
        {
          'num': '1',
          'title': 'Chọn 3 món đồ xô lệch',
          'desc': 'Kéo thẳng góc chăn giường hoặc chọn 3 món đồ đang bừa bộn trên bàn làm việc.',
        },
        {
          'num': '2',
          'title': 'Đặt lại trong chậm rãi',
          'desc': 'Đưa từng món về đúng vị trí trong tĩnh lặng, không vội vã.',
        },
        {
          'num': '3',
          'title': 'Ngắm nhìn khoảng trống',
          'desc': 'Cảm nhận trật tự bên ngoài đang phản chiếu sự ngăn nắp, rõ ràng trong tâm trí.',
        },
      ],
      buttonText: "Góc nhỏ gọn gàng • Tâm trí sáng rõ",
    );
  }

  // --- 11. RITUAL MỚI: 5 TRANG SÁCH BAN MAI (Bài 74) ---
  Widget _buildReadPagesBody() {
    return _buildGuidedPebbleBody(
      badge: "5 TRANG SÁCH BAN MAI",
      title: "Đồng hành cùng tư duy sâu lắng",
      icon: Icons.menu_book_rounded,
      accentColor: const Color(0xFF8B5CF6),
      bookArticle: "Bài 74: Năm Trang Sách",
      bookQuote: "Năm trang sách mỗi ngày không phải để thành người đọc nhiều — mà để dành 15 phút đồng hành với tư duy của người khác.",
      steps: const [
        {
          'num': '1',
          'title': 'Mở trang sách yêu thích',
          'desc': 'Không áp lực phải đọc hết chương, chỉ cần một cuốn sách nuôi dưỡng bạn.',
        },
        {
          'num': '2',
          'title': 'Đọc chậm từng câu từ',
          'desc': 'Dừng lại ở những câu nói chạm đến lòng bạn, nhấp một ngụm trà hoặc nước.',
        },
        {
          'num': '3',
          'title': 'Khép sách trong tĩnh lặng',
          'desc': 'Ghi nhận một góc nhìn mới vừa mở ra trong tâm thức bạn sáng nay.',
        },
      ],
      buttonText: "Đã nạp dưỡng chất • Tâm trí mở mang",
    );
  }

  // --- 12. RITUAL MỚI: QUY TẮC 5 PHÚT (Bài 64) ---
  Widget _buildFiveMinRuleBody() {
    return _buildGuidedPebbleBody(
      badge: "QUY TẮC 5 PHÚT",
      title: "Vượt qua sự tê liệt vì quá tải",
      icon: Icons.timer_outlined,
      accentColor: const Color(0xFF06B6D4),
      bookArticle: "Bài 64: Quy Tắc 5 Phút",
      bookQuote: "Khi mọi thứ cảm thấy quá lớn, bắt đầu từ thứ nhỏ nhất bạn có thể làm ngay bây giờ.",
      steps: const [
        {
          'num': '1',
          'title': 'Chọn việc đang trì hoãn',
          'desc': 'Một email khó trả lời, một tài liệu cần đọc hay một việc nhà đang ngại.',
        },
        {
          'num': '2',
          'title': 'Thỏa thuận với bản thân',
          'desc': 'Nói với mình: "Tôi chỉ làm đúng 5 phút thôi, sau đó tôi được quyền dừng lại."',
        },
        {
          'num': '3',
          'title': 'Hành động vi mô ngay',
          'desc': 'Bắt đầu bước nhỏ nhất trong 5 phút. Bạn sẽ ngạc nhiên vì quán tính đã tan biến.',
        },
      ],
      buttonText: "Đã vượt qua quán tính ban đầu",
    );
  }

  // --- 13. RITUAL MỚI: GỬI MỘT TIN NHẮN TỬ TẾ (Bài 70) ---
  Widget _buildKindMessageBody() {
    return _buildGuidedPebbleBody(
      badge: "TIN NHẮN TỬ TẾ",
      title: "Để ai đó thấy mình được nhìn thấy",
      icon: Icons.favorite_border_rounded,
      accentColor: const Color(0xFFEC4899),
      bookArticle: "Bài 70: Tin Nhắn Tử Tế",
      bookQuote: "Một tin nhắn tử tế gửi đi — và bạn vừa làm ai đó thấy mình được nhìn thấy giữa thế giới hối hả này.",
      steps: const [
        {
          'num': '1',
          'title': 'Nghĩ về một người quen',
          'desc': 'Một người bạn cũ, người thân hay đồng nghiệp đã lâu bạn chưa trò chuyện.',
        },
        {
          'num': '2',
          'title': 'Gửi lời hỏi thăm chân thật',
          'desc': 'Không vì mục đích công việc. Chỉ là một lời cảm ơn hay chúc một ngày an lành.',
        },
        {
          'num': '3',
          'title': 'Cảm nhận hơi ấm lan tỏa',
          'desc': 'Khi bạn trao đi sự tử tế, chính trái tim bạn là nơi đầu tiên được sưởi ấm.',
        },
      ],
      buttonText: "Đã gửi đi sự ấm áp chân thành",
    );
  }

  // --- 14. RITUAL MỚI: ĐI BỘ KHÔNG ĐIỆN THOẠI (Bài 67) ---
  Widget _buildWalkUnpluggedBody() {
    return _buildGuidedPebbleBody(
      badge: "ĐI BỘ THONG THẢ",
      title: "Cho phép mình chỉ là mình",
      icon: Icons.directions_walk_rounded,
      accentColor: const Color(0xFF14B8A6),
      bookArticle: "Bài 67: Đi Bộ Rời Màn Hình",
      bookQuote: "Đi bộ không điện thoại không phải liệu pháp — mà là khoảng thời gian bạn cho phép mình chỉ đơn thuần là tồn tại.",
      steps: const [
        {
          'num': '1',
          'title': 'Để điện thoại lại',
          'desc': 'Cất điện thoại vào túi hoặc để lại trên bàn, không mang tai nghe.',
        },
        {
          'num': '2',
          'title': 'Bước đi thong dong 5 phút',
          'desc': 'Cảm nhận bàn chân chạm đất, ngắm nhìn vòm lá và bầu trời chiều.',
        },
        {
          'num': '3',
          'title': 'Không cần tối ưu hóa',
          'desc': 'Không đo đếm bước chân. Chỉ là bạn, đang hiện diện giữa không gian sống.',
        },
      ],
      buttonText: "Tâm trí đã được trả tự do",
    );
  }

  // --- 15. RITUAL MỚI: 3 ĐIỀU BIẾT ƠN TRƯỚC KHI NGỦ (Bài 68) ---
  Widget _buildThreeGratitudesBody() {
    return _buildGuidedPebbleBody(
      badge: "3 ĐIỀU BIẾT ƠN CUỐI NGÀY",
      title: "Nhận ra những gì đang thực sự có",
      icon: Icons.auto_awesome_rounded,
      accentColor: AppColors.secondary,
      bookArticle: "Bài 68: Ba Điều Biết Ơn",
      bookQuote: "Không phải để tích cực hóa, mà để nhận ra giữa vô vàn xáo động, vẫn có những điều có thật đang hiện diện.",
      steps: const [
        {
          'num': '1',
          'title': 'Một điều nhỏ đã nâng đỡ bạn',
          'desc': 'Một ngụm trà ngon, một cơn gió mát hay một góc ngồi êm ái hôm nay.',
        },
        {
          'num': '2',
          'title': 'Một sự tử tế đã nhận được',
          'desc': 'Một nụ cười của ai đó, một lời nhắc nhở hay một cử chỉ kiên nhẫn.',
        },
        {
          'num': '3',
          'title': 'Cảm ơn chính cơ thể mình',
          'desc': 'Biết ơn đôi chân, đôi mắt và trái tim đã bền bỉ đưa bạn đi qua một ngày trọn vẹn.',
        },
      ],
      buttonText: "Lòng ngập tràn sự biết ơn giản dị",
    );
  }

  // --- 16. RITUAL MỚI: TẮM NƯỚC ẤM XẢ TRÔI (Bài 89) ---
  Widget _buildShowerCleanseBody() {
    return _buildGuidedPebbleBody(
      badge: "GỘT RỬA BẰNG NƯỚC ẤM",
      title: "Để mọi gánh nặng được phép trôi đi",
      icon: Icons.shower_rounded,
      accentColor: const Color(0xFF38BDF8),
      bookArticle: "Bài 89: Nước Chảy Qua Người",
      bookQuote: "Nước chảy qua người bạn trong vòi hoa sen — và cùng với nó, những mệt mỏi được phép trôi đi theo dòng nước.",
      steps: const [
        {
          'num': '1',
          'title': 'Đứng dưới dòng nước ấm',
          'desc': 'Khép nhẹ mắt lại, để dòng nước bao bọc đỉnh đầu, bờ vai và sống lưng.',
        },
        {
          'num': '2',
          'title': 'Thả trôi mọi bụi bặm',
          'desc': 'Hình dung mọi lời nói nặng nề, căng thẳng trong ngày đang tan thành bọt nước.',
        },
        {
          'num': '3',
          'title': 'Thở ra nhẹ nhõm',
          'desc': 'Cảm nhận cơ thể nhẹ bẫng, sạch sẽ và sẵn sàng đón nhận giấc ngủ sâu.',
        },
      ],
      buttonText: "Mọi gánh nặng đã theo nước trôi đi",
    );
  }

  // --- HÀM TẠO KHUNG GUIDED PEBBLE CHUNG (ĐÍNH KÈM TRIẾT LÝ MẠCH 3) ---
  Widget _buildGuidedPebbleBody({
    required String badge,
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Map<String, String>> steps,
    required String buttonText,
    String? bookArticle,
    String? bookQuote,
  }) {
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
                  color: accentColor.withValues(alpha: 0.15),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                badge,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Khung trích dẫn triết lý từ sách Mạch 3 (nếu có)
        if (bookArticle != null && bookQuote != null) ...[
          _buildBookQuoteBadge(bookArticle, bookQuote, accentColor),
          const SizedBox(height: 16),
        ],

        // Danh sách các bước
        ...steps.map((s) => _buildStepCard(s['num']!, s['title']!, s['desc']!, accentColor)),

        const SizedBox(height: 20),
        ZenButton(
          text: buttonText,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildBookQuoteBadge(String article, String quote, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_stories_outlined, size: 18, color: accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mạch 3: Hành Động Nhỏ • $article",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "\"$quote\"",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String desc, Color accentColor) {
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
              color: accentColor.withValues(alpha: 0.2),
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accentColor,
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
