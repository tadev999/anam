import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../daily_anchor/bloc/anchor_bloc.dart';
import '../../../daily_anchor/data/models/anchor_model.dart';
import '../../../daily_anchor/presentation/screens/anchor_view.dart';
import '../../../daily_anchor/presentation/screens/evening_reflection_view.dart';
import '../../../sleep_seed/bloc/sleep_seed_bloc.dart';
import '../../../sleep_seed/bloc/sleep_seed_event.dart';
import '../../../sleep_seed/bloc/sleep_seed_state.dart';
import '../../../sleep_seed/presentation/screens/sleep_seed_screen.dart';
import '../widgets/micro_ritual_sheet.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;
  late final AnimationController _entranceController;
  int _pebbleShuffleOffset = 0;

  @override
  void initState() {
    super.initState();

    // 1. Setup Hearth Breathing animation guide (8s cycle)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    // 2. Setup Staggered Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entranceController.forward();
        final authState = BlocProvider.of<AuthBloc>(context).state;
        if (authState is Authenticated) {
          BlocProvider.of<AnchorBloc>(context).add(
            CheckTodayAnchorRequested(authState.user.uid, _getTodayString()),
          );
          BlocProvider.of<SleepSeedBloc>(context).add(
            CheckSleepSeedStatusRequested(
              authState.user.uid,
              _getTodayString(),
            ),
          );
        }
      }
    });
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _getFormattedHeaderDate() {
    final now = DateTime.now();
    const weekdays = [
      'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'
    ];
    final weekday = weekdays[now.weekday - 1];
    return '$weekday, ${now.day} Th${now.month}';
  }

  String _getCircadianGreetingTitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Chào Ngày Mới Nhẹ Nhõm";
    } else if (hour >= 12 && hour < 18) {
      return "Bình Yên Giữa Ngày";
    } else if (hour >= 18 && hour < 22) {
      return "Buổi Tối An Lành";
    } else {
      return "Đêm Đã Về Khuya";
    }
  }

  String _getCircadianLeadingPhrase() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Bắt đầu ngày mới từ sự tĩnh tại bên trong chính bạn.";
    } else if (hour >= 12 && hour < 18) {
      return "Dừng lại một nhịp thở giữa dòng chảy hối hả của ngày.";
    } else if (hour >= 18 && hour < 22) {
      return "Một ngày khép lại khi lòng bạn bắt đầu an yên.";
    } else {
      return "Màn đêm buông xuống, hãy để tâm trí được nghỉ ngơi trọn vẹn.";
    }
  }

  String _getHeroSectionTitle(int hour, bool isEveningCompleted) {
    if (hour >= 17 || hour < 5) {
      if (isEveningCompleted && (hour >= 21 || hour < 5)) {
        return "GIẤC NGỦ AN LÀNH";
      }
      return "LẮNG ĐỌNG CUỐI NGÀY";
    } else {
      return "Ý NIỆM TRONG NGÀY";
    }
  }

  String _getFocalQuestion() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return ZenConstants.tridayQuestions['morning'] ??
          "Hôm nay bạn hành động từ nỗi sợ thiếu hụt, hay từ nền tảng vững chắc bên trong?";
    } else if (hour >= 12 && hour < 18) {
      return ZenConstants.tridayQuestions['afternoon'] ??
          "Thứ gì đang thật sự nuôi dưỡng bạn — không phải kích thích bạn?";
    } else {
      return ZenConstants.tridayQuestions['evening'] ??
          "Bạn là ai khi không có ai nhìn?";
    }
  }

  List<Map<String, dynamic>> _getCircadianPebblePool() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      // Sáng (Morning): Đánh thức sinh học & nạp năng lượng (Mạch 3)
      return [
        {
          'title': 'Uống nước ấm',
          'subtitle': 'Ấm áp • Tế bào',
          'icon': Icons.water_drop_outlined,
          'type': MicroRitualType.water,
        },
        {
          'title': 'Đón nắng sớm',
          'subtitle': 'Kích hoạt Serotonin',
          'icon': Icons.wb_sunny_outlined,
          'type': MicroRitualType.sunlight,
        },
        {
          'title': 'Vươn vai',
          'subtitle': 'Đón dưỡng khí',
          'icon': Icons.self_improvement_rounded,
          'type': MicroRitualType.stretch,
        },
        {
          'title': 'Sắp góc nhỏ',
          'subtitle': 'Xứng đáng bắt đầu',
          'icon': Icons.cleaning_services_rounded,
          'type': MicroRitualType.tidySpace,
        },
        {
          'title': '5 hơi thở sâu',
          'subtitle': 'Khởi đầu tĩnh tại',
          'icon': Icons.air_rounded,
          'type': MicroRitualType.breathing,
        },
        {
          'title': '5 trang sách',
          'subtitle': '15p lắng nghe',
          'icon': Icons.menu_book_rounded,
          'type': MicroRitualType.readPages,
        },
      ];
    } else if (hour >= 11 && hour < 17) {
      // Chiều (Afternoon): Giải tỏa căng thẳng, hạ nhiệt giữa ngày (Mạch 3)
      return [
        {
          'title': '5 hơi thở sâu',
          'subtitle': 'Lắng dịu • Tự tại',
          'icon': Icons.air_rounded,
          'type': MicroRitualType.breathing,
        },
        {
          'title': 'Nghỉ mắt 60s',
          'subtitle': 'Quy tắc 20-20-20',
          'icon': Icons.visibility_outlined,
          'type': MicroRitualType.restEyes,
        },
        {
          'title': 'Thả lỏng vai',
          'subtitle': 'Buông gánh nặng',
          'icon': Icons.accessibility_new_rounded,
          'type': MicroRitualType.shoulder,
        },
        {
          'title': 'Quy tắc 5 phút',
          'subtitle': 'Bắt đầu việc nhỏ',
          'icon': Icons.timer_outlined,
          'type': MicroRitualType.fiveMinRule,
        },
        {
          'title': 'Tin tử tế',
          'subtitle': 'Gửi lời chân thành',
          'icon': Icons.favorite_border_rounded,
          'type': MicroRitualType.kindMessage,
        },
        {
          'title': 'Đi bộ thong thả',
          'subtitle': 'Rời xa màn hình',
          'icon': Icons.directions_walk_rounded,
          'type': MicroRitualType.walkUnplugged,
        },
      ];
    } else {
      // Tối / Đêm (Evening & Night): Thư giãn sâu, vỗ về & chuyển giao giấc ngủ (Mạch 3)
      return [
        {
          'title': 'Thở dài trút bỏ',
          'subtitle': 'Hạ Cortisol tức thì',
          'icon': Icons.spa_outlined,
          'type': MicroRitualType.sigh,
        },
        {
          'title': 'Xoa ấm mắt',
          'subtitle': 'Vỗ về thị giác',
          'icon': Icons.back_hand_outlined,
          'type': MicroRitualType.handWarmth,
        },
        {
          'title': 'Đặt tay lên tim',
          'subtitle': 'Tự trắc ẩn & an yên',
          'icon': Icons.favorite_outline_rounded,
          'type': MicroRitualType.gratitudeChest,
        },
        {
          'title': '3 điều biết ơn',
          'subtitle': 'Nhận ra điều có sẵn',
          'icon': Icons.auto_awesome_rounded,
          'type': MicroRitualType.threeGratitudes,
        },
        {
          'title': 'Tắm xả buông',
          'subtitle': 'Trôi đi mệt mỏi',
          'icon': Icons.shower_rounded,
          'type': MicroRitualType.showerCleanse,
        },
        {
          'title': 'Thả lỏng vai',
          'subtitle': 'Rũ bỏ mệt mỏi',
          'icon': Icons.accessibility_new_rounded,
          'type': MicroRitualType.shoulder,
        },
      ];
    }
  }

  String _getCircadianPebbleSectionTitle() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) {
      return "NUÔI DƯỠNG BUỔI SÁNG";
    } else if (hour >= 11 && hour < 17) {
      return "HẠ NHIỆT GIỮA NGÀY";
    } else {
      return "VỖ VỀ BUỔI TỐI";
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Nền Dark Luxury chuẩn an_match
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    Color(0xFF131A26),
                    Color(0xFF0F151F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Hiệu ứng hạt bụi sáng bay lơ lửng rất dịu nhẹ (0% CPU Rebuild overhead)
          const Positioned.fill(child: _AmbientFloatingDust()),

          // Đốm sáng Hổ phách ấm áp nhịp thở mờ nhẹ góc dưới
          Positioned(
            bottom: -100,
            right: -100,
            child: ScaleTransition(
              scale: _breathingAnimation,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
          ),

          // Đốm sáng radar teal mờ góc trên trái — tạo chiều sâu thoáng chuẩn an_match
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.radarActive.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: MultiBlocListener(
              listeners: [
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, authState) {
                    if (authState is Authenticated) {
                      BlocProvider.of<AnchorBloc>(context).add(
                        CheckTodayAnchorRequested(
                          authState.user.uid,
                          _getTodayString(),
                        ),
                      );
                      BlocProvider.of<SleepSeedBloc>(context).add(
                        CheckSleepSeedStatusRequested(
                          authState.user.uid,
                          _getTodayString(),
                        ),
                      );
                    }
                  },
                ),
                BlocListener<SleepSeedBloc, SleepSeedState>(
                  listener: (context, sleepState) {
                    if (sleepState is SleepSeedStatusLoaded) {
                      if (sleepState.canSprout &&
                          sleepState.yesterdayAnchor != null) {
                        Future.delayed(const Duration(milliseconds: 800), () {
                          if (mounted && context.mounted) {
                            _showMorningSproutDialog(
                              context,
                              sleepState.yesterdayAnchor!,
                            );
                          }
                        });
                      }
                    } else if (sleepState is SleepSeedCollectionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "🌱 Đã đón nhận mầm bình yên vào Vườn Tâm Trí!",
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: ZenTheme.sageGreen,
                        ),
                      );
                      final authState = BlocProvider.of<AuthBloc>(
                        context,
                      ).state;
                      if (authState is Authenticated) {
                        BlocProvider.of<SleepSeedBloc>(context).add(
                          CheckSleepSeedStatusRequested(
                            authState.user.uid,
                            _getTodayString(),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return BlocBuilder<AnchorBloc, AnchorState>(
                    builder: (context, anchorState) {
                      AnchorModel? anchor;
                      if (anchorState is AnchorLoadSuccess) {
                        anchor = anchorState.anchor;
                      } else if (anchorState is AnchorSubmissionSuccess) {
                        anchor = anchorState.anchor;
                      } else if (anchorState is EveningReflectionSuccess) {
                        anchor = anchorState.anchor;
                      }
                      final isEveningCompleted =
                          anchor?.eveningCompleted ?? false;

                      // Xây dựng danh sách thành phần Home tối giản, thanh nhã (Sanctuary Zen)
                      final List<Widget> children = [];

                      // 1. Header tinh tế đồng nhất (Sanctuary Header Standard)
                      children.add(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tầng 1: Eyebrow row (Tag pill bên trái + Date badge bên phải)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.spa_rounded,
                                        color: AppColors.primary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "AN TRÚ THƯỜNG NHẬT",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.8,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: Text(
                                    _getFormattedHeaderDate(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Tầng 2: Title lớn thời khắc sinh học (Buông bỏ danh xưng, trở về thực tại)
                            Text(
                              _getCircadianGreetingTitle(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Tầng 3: Dòng dẫn dịu lành
                            Text(
                              _getCircadianLeadingPhrase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );

                      // 2. Tiêu điểm hành động duy nhất theo thời khắc (Single Primary Hero Card)
                      final hour = DateTime.now().hour;
                      children.add(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _getHeroSectionTitle(hour, isEveningCompleted),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildHeroAnchorCard(
                              context,
                              anchor,
                              hour,
                              isEveningCompleted,
                            ),
                          ],
                        ),
                      );

                      // 4. Dòng chảy sỏi sinh học (Circadian Dynamic Pebbles)
                      children.add(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getCircadianPebbleSectionTitle(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _pebbleShuffleOffset++;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.shuffle_rounded,
                                            size: 13,
                                            color: AppColors.primaryLight,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Đổi sỏi",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildMicroOfferingsRow(context),
                          ],
                        ),
                      );

                      // 4. Footer Tagline
                      children.add(
                        Center(
                          child: Text(
                            "Anam • A Secular Sanctuary for Mindful Souls",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < children.length; i++) ...[
                              _StaggeredEntranceItem(
                                key: ValueKey('entrance_$i'),
                                index: i,
                                controller: _entranceController,
                                child: children[i],
                              ),
                              if (i < children.length - 1)
                                SizedBox(height: i == 0 ? 28 : 32),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAnchorCard(
    BuildContext context,
    AnchorModel? anchor,
    int hour,
    bool isEveningCompleted,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final isMorningCompleted = anchor?.morningCompleted ?? false;

    // 1. Buổi tối & Đêm (17h - 5h sáng)
    if (hour >= 17 || hour < 5) {
      if (isEveningCompleted) {
        // Đã hoàn thành nhìn lại tối:
        if (hour >= 21 || hour < 5) {
          // Khuya: Gieo hạt mầm ngủ ngon
          return _buildSleepSeedCard(context, isNight: true);
        } else {
          // 17h - 21h: Thẻ Một ngày đã trọn vẹn
          return _buildCompletedAnchorCard(context, textTheme, anchor!);
        }
      } else {
        // Chưa nhìn lại tối -> Mời gọi Cùng khép lại một ngày (Lắng đọng cuối ngày)
        return _buildEveningReflectionCard(
          context,
          textTheme,
          anchor ??
              AnchorModel(
                id: '',
                uid: '',
                date: _getTodayString(),
                affirmationText: '',
                microOfferingId: '',
                intention: '',
              ),
        );
      }
    }

    // 2. Ban ngày (5h - 17h)
    if (!isMorningCompleted || anchor == null) {
      // Chưa gieo neo sáng -> Mời gieo ý niệm ngày mới
      return _buildMorningAnchorCard(context, textTheme);
    } else {
      // Đã gieo neo sáng -> Thẻ Ý niệm đang đồng hành
      return _buildActiveDaytimeAnchorCard(context, textTheme, anchor);
    }
  }

  Widget _buildMicroOfferingsRow(BuildContext context) {
    final pool = _getCircadianPebblePool();
    final actions = List.generate(
      3,
      (i) => pool[(i + _pebbleShuffleOffset) % pool.length],
    );

    return Row(
      children: actions.map((act) {
        final type = act['type'] as MicroRitualType;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  splashColor: AppColors.primary.withValues(alpha: 0.15),
                  highlightColor: AppColors.primary.withValues(alpha: 0.08),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    MicroRitualSheet.show(context, type);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            act['icon'] as IconData,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          act['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          act['subtitle'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildMorningAnchorCard(BuildContext context, TextTheme textTheme) {
    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnchorView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.sageGreen.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_outlined,
                      color: ZenTheme.sageGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ý niệm ngày mới",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Định hình ý niệm & hành động",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: ZenTheme.sageGreen.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ZenTheme.sageGreen.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Gieo một ý niệm lành mạnh cho ngày hôm nay:",
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGray.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.creamWhite.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ZenTheme.creamWhite.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  "\"${_getFocalQuestion()}\"",
                  style: textTheme.bodyMedium!.copyWith(
                    color: ZenTheme.creamWhite.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.sageGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Thiết lập ý định ngày mới",
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.sageGreen,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: ZenTheme.sageGreen,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDaytimeAnchorCard(
    BuildContext context,
    TextTheme textTheme,
    AnchorModel anchor,
  ) {
    const accentColor = AppColors.primary;
    final intentionText = anchor.intention.isNotEmpty
        ? anchor.intention
        : (anchor.affirmationText.isNotEmpty
            ? anchor.affirmationText
            : "Sống trọn vẹn và an định trong từng khoảnh khắc");

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnchorView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ý niệm đang đồng hành",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Nuôi dưỡng tâm thế an định",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: accentColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Sáng nay bạn đã chọn neo đậu vào ý niệm:",
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGray.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.creamWhite.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ZenTheme.creamWhite.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  "\"$intentionText\"",
                  style: textTheme.bodyMedium!.copyWith(
                    color: ZenTheme.creamWhite.withValues(alpha: 0.9),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Hãy giữ tâm thế này trong từng hơi thở và hành động giữa ngày bận rộn.",
                style: textTheme.bodyMedium!.copyWith(
                  fontSize: 12.5,
                  color: ZenTheme.softGray,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Xem lại ý niệm & bài học",
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: accentColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEveningReflectionCard(
    BuildContext context,
    TextTheme textTheme,
    AnchorModel anchor,
  ) {
    const eveningColor = Color(0xff8b7cf8);
    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EveningReflectionView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: eveningColor.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.nightlight_outlined,
                      color: eveningColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cùng khép lại một ngày",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Lắng đọng & Ghi nhận bài học",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: eveningColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      eveningColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (anchor.intention.isNotEmpty) ...[
                Text(
                  "Sáng nay bạn đã đặt ý định:",
                  style: textTheme.bodyMedium!.copyWith(
                    color: ZenTheme.softGray.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ZenTheme.creamWhite.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ZenTheme.creamWhite.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    "\"${anchor.intention}\"",
                    style: textTheme.bodyMedium!.copyWith(
                      color: ZenTheme.creamWhite.withValues(alpha: 0.85),
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                "Dành vài phút nhìn lại để trút bỏ mọi gánh nặng trước khi bước vào giấc ngủ.",
                style: textTheme.bodyMedium!.copyWith(
                  fontSize: 13,
                  color: ZenTheme.softGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: eveningColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eveningColor.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bắt đầu nhìn lại",
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: eveningColor,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: eveningColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedAnchorCard(
    BuildContext context,
    TextTheme textTheme,
    AnchorModel anchor,
  ) {
    const completedColor = ZenTheme.softGold;
    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EveningReflectionView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completedColor.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: completedColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Một ngày đã trọn vẹn",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tâm trí lắng yên & thảnh thơi",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: completedColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      completedColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Bạn đã đồng hành cùng chính mình trọn vẹn một ngày. Mọi âu lo đã được gửi lại phía sau, hãy để cơ thể và tâm hồn được nghỉ ngơi sâu.",
                style: textTheme.bodyMedium!.copyWith(
                  fontSize: 13,
                  color: ZenTheme.softGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.sageGreen.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Xem lại nhật ký hôm nay",
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.sageGreen,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: ZenTheme.sageGreen,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSeedCard(BuildContext context, {required bool isNight}) {
    final textTheme = Theme.of(context).textTheme;

    if (isNight) {
      return _PebblePressCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepSeedScreen()),
        ),
        child: GlassContainer(
          opacity: 0.15,
          radius: 24,
          padding: const EdgeInsets.all(0),
          border: Border.all(
            color: ZenTheme.sageGreen.withValues(alpha: 0.35),
            width: 1.5,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ZenTheme.sageGreen.withValues(alpha: 0.18),
                        boxShadow: [
                          BoxShadow(
                            color: ZenTheme.sageGreen.withValues(alpha: 0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: ZenTheme.sageGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Hạt mầm ngủ ngon",
                                style: textTheme.headlineSmall!.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ZenTheme.creamWhite,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ZenTheme.sageGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "Đêm lành",
                                  style: textTheme.bodyMedium!.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: ZenTheme.sageGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Buông bỏ & Chìm vào giấc ngủ tự nhiên",
                            style: textTheme.bodyMedium!.copyWith(
                              fontSize: 12,
                              color: ZenTheme.sageGreen.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ZenTheme.sageGreen.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Đêm đã về. Gieo một hạt mầm bình yên và khép lại ngày hôm nay trong tĩnh lặng.",
                  style: textTheme.bodyMedium!.copyWith(
                    fontSize: 13,
                    color: ZenTheme.softGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: ZenTheme.sageGreen.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ZenTheme.sageGreen.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Gieo hạt mầm ngủ ngon",
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ZenTheme.creamWhite,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: ZenTheme.creamWhite,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return _PebblePressCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SleepSeedScreen()),
        ),
        child: Opacity(
          opacity: 0.65,
          child: GlassContainer(
            opacity: 0.06,
            radius: 24,
            padding: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.sageGreen.withValues(alpha: 0.08),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: ZenTheme.softGray,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Hạt mầm ngủ ngon",
                          style: textTheme.titleLarge!.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ZenTheme.creamWhite.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Chờ bóng tối màn đêm (Mở sau 21h00)",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 13,
                            color: ZenTheme.softGray.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: ZenTheme.softGray,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showMorningSproutDialog(
    BuildContext context,
    AnchorModel yesterdayAnchor,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "MorningSprout",
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (ctx, anim1, anim2) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: const Color(0xFF08080C).withValues(alpha: 0.85),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ZenTheme.sageGreen.withValues(alpha: 0.05),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: anim1,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZenTheme.sageGreen.withValues(alpha: 0.12),
                            boxShadow: [
                              BoxShadow(
                                color: ZenTheme.sageGreen.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text("🌱", style: TextStyle(fontSize: 48)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Mầm xanh an trú nảy nở",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ZenTheme.creamWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Chào buổi sáng. Hạt mầm ngủ ngon bạn gieo đêm qua đã nảy mầm trong tĩnh lặng của màn đêm. Hãy đưa chiếc mầm này vào Vườn Tâm Trí của bạn.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ZenTheme.softGray.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      ZenButton.glass(
                        text: "Nhận mầm bình yên",
                        onPressed: () {
                          BlocProvider.of<SleepSeedBloc>(context).add(
                            CollectSleepSproutRequested(
                              uid: yesterdayAnchor.uid,
                              date: yesterdayAnchor.date,
                              sproutedAt: DateTime.now(),
                            ),
                          );
                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PebblePressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PebblePressCard({required this.child, required this.onTap});

  @override
  State<_PebblePressCard> createState() => _PebblePressCardState();
}

class _PebblePressCardState extends State<_PebblePressCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.95);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _StaggeredEntranceItem extends StatefulWidget {
  final Widget child;
  final int index;
  final AnimationController controller;

  const _StaggeredEntranceItem({
    super.key,
    required this.child,
    required this.index,
    required this.controller,
  });

  @override
  State<_StaggeredEntranceItem> createState() => _StaggeredEntranceItemState();
}

class _StaggeredEntranceItemState extends State<_StaggeredEntranceItem> {
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    final double start = (widget.index * 0.12).clamp(0.0, 0.6);
    final double end = (start + 0.35).clamp(0.0, 1.0);

    final curvedAnimation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _offset = Tween<Offset>(
      begin: const Offset(0.0, 0.12),
      end: Offset.zero,
    ).animate(curvedAnimation);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _AmbientFloatingDust extends StatefulWidget {
  const _AmbientFloatingDust();

  @override
  State<_AmbientFloatingDust> createState() => _AmbientFloatingDustState();
}

class _AmbientFloatingDustState extends State<_AmbientFloatingDust>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DustPainter(animation: _controller),
      child: const SizedBox.expand(),
    );
  }
}

class _DustPainter extends CustomPainter {
  final Animation<double> animation;

  _DustPainter({required this.animation}) : super(repaint: animation);

  static final List<_ParticleSeed> _seeds = [
    _ParticleSeed(
      startX: 0.15,
      startY: 0.25,
      speedX: 0.05,
      speedY: 0.08,
      size: 4.5,
      baseOpacity: 0.20,
    ),
    _ParticleSeed(
      startX: 0.85,
      startY: 0.15,
      speedX: -0.06,
      speedY: 0.07,
      size: 3.5,
      baseOpacity: 0.16,
    ),
    _ParticleSeed(
      startX: 0.45,
      startY: 0.65,
      speedX: 0.04,
      speedY: -0.05,
      size: 5.0,
      baseOpacity: 0.18,
    ),
    _ParticleSeed(
      startX: 0.25,
      startY: 0.75,
      speedX: -0.05,
      speedY: -0.06,
      size: 4.0,
      baseOpacity: 0.22,
    ),
    _ParticleSeed(
      startX: 0.75,
      startY: 0.80,
      speedX: 0.07,
      speedY: -0.04,
      size: 3.0,
      baseOpacity: 0.14,
    ),
    _ParticleSeed(
      startX: 0.60,
      startY: 0.35,
      speedX: -0.03,
      speedY: 0.09,
      size: 4.2,
      baseOpacity: 0.17,
    ),
    _ParticleSeed(
      startX: 0.35,
      startY: 0.50,
      speedX: 0.06,
      speedY: 0.05,
      size: 2.8,
      baseOpacity: 0.13,
    ),
    _ParticleSeed(
      startX: 0.90,
      startY: 0.55,
      speedX: -0.04,
      speedY: -0.07,
      size: 3.8,
      baseOpacity: 0.15,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ZenTheme.softGold;
    final t = animation.value;

    for (final seed in _seeds) {
      final dx = (seed.startX + seed.speedX * sin(t * 2 * pi)) * size.width;
      final dy = (seed.startY + seed.speedY * cos(t * 2 * pi)) * size.height;

      final opacity =
          seed.baseOpacity * (0.6 + 0.4 * sin(t * 4 * pi + seed.startX * 10));
      paint.color = ZenTheme.softGold.withValues(
        alpha: opacity.clamp(0.0, 1.0),
      );

      canvas.drawCircle(Offset(dx, dy), seed.size, paint);
    }
  }

  @override
  bool shouldRepaint(_DustPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _ParticleSeed {
  final double startX;
  final double startY;
  final double speedX;
  final double speedY;
  final double size;
  final double baseOpacity;

  const _ParticleSeed({
    required this.startX,
    required this.startY,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.baseOpacity,
  });
}
