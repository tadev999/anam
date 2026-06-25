import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../daily_anchor/bloc/anchor_bloc.dart';
import '../../../daily_anchor/data/models/anchor_model.dart';
import '../../../daily_anchor/presentation/screens/anchor_view.dart';
import '../../../daily_anchor/presentation/screens/evening_reflection_view.dart';
import '../../../release_space/presentation/screens/release_view.dart';
import '../../../hearth/presentation/screens/hearth_view.dart';
import '../../../silence/presentation/screens/silence_view.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';
import '../../../mind_garden/bloc/mind_garden_bloc.dart';
import '../../../mind_garden/presentation/screens/mind_garden_screen.dart';
import '../../../sleep_seed/bloc/sleep_seed_bloc.dart';
import '../../../sleep_seed/bloc/sleep_seed_event.dart';
import '../../../sleep_seed/bloc/sleep_seed_state.dart';
import '../../../sleep_seed/presentation/screens/sleep_seed_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final String _comfortQuote;
  late final AnimationController _breathingController;
  late final Animation<double> _breathingAnimation;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _comfortQuote = ZenConstants
        .hearthQuotes[random.nextInt(ZenConstants.hearthQuotes.length)];

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

  String _getGreetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Chào ngày mới nhẹ nhõm,";
    } else if (hour >= 12 && hour < 17) {
      return "Bình yên giữa ngày,";
    } else {
      return "Khép lại ngày, thả lỏng...";
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Nền Zen tối thâm trầm
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZenTheme.slateDark, Color(0xff0d1115)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Hiệu ứng hạt bụi sáng bay lơ lửng rất dịu nhẹ (0% CPU Rebuild overhead)
          const Positioned.fill(child: _AmbientFloatingDust()),

          // Đốm sáng Bếp Lửa nhịp thở mờ nhẹ góc dưới
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
                  color: ZenTheme.softGold.withOpacity(0.09),
                ),
              ),
            ),
          ),

          // Đốm sáng sage mờ góc trên trái — tạo chiều sâu thoáng
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZenTheme.sageGreen.withOpacity(0.07),
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
                          if (mounted) {
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
                builder: (context, state) {
                  final user = (state is Authenticated) ? state.user : null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22.0,
                      vertical: 24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Thanh tiêu đề trên cùng (Header)
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_0'),
                          index: 0,
                          controller: _entranceController,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreetingPrefix(),
                                    style: textTheme.bodyMedium,
                                  ),
                                  Text(
                                    user?.displayName ?? "Lữ khách",
                                    style: textTheme.displayMedium!.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.logout,
                                      color: ZenTheme.softGray,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      BlocProvider.of<AuthBloc>(
                                        context,
                                      ).add(SignOutRequested());
                                    },
                                    tooltip: "Rời chốn bình yên",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 1. Khoảnh Khắc Trong Ngày — PRIMARY, luôn đứng đầu
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_1'),
                          index: 1,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Khoảnh khắc trong ngày",
                                style: textTheme.displaySmall!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ZenTheme.sageGreen,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildMainAnchorCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 2. Khoảng Lặng — công cụ điều hoà cảm xúc (regulation)
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_2'),
                          index: 2,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Khoảng lặng",
                                style: textTheme.displaySmall!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ZenTheme.inkBlue,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSilenceCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 3. Tự Thấu Hiểu — chiêm nghiệm sâu (Gương tự vấn)
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_3'),
                          index: 3,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Tự thấu hiểu",
                                style: textTheme.displaySmall!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ZenTheme.softGold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildReflectionCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 4. Khoảng Buông — xả & giải phóng cảm xúc nặng nề
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_4'),
                          index: 4,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Khoảng buông",
                                style: textTheme.displaySmall!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ZenTheme.mistRed,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildReleaseCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 5. Giấc ngủ bình yên / Hạt mầm ngủ ngon
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_sleep'),
                          index: 5,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Giấc ngủ bình yên",
                                style: textTheme.displaySmall!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ZenTheme.sageGreen,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSleepSeedCard(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 6. Kết Nối & Nhìn Lại — Bếp lửa chung + Vườn Tâm Trí
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_6'),
                          index: 6,
                          controller: _entranceController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Kết nối & Nhìn lại",
                                style: textTheme.bodyMedium!.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ZenTheme.softGray.withOpacity(0.6),
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildConnectionRow(context),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 7. Bếp lửa sưởi ấm — ambient, cuối trang
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_7'),
                          index: 7,
                          controller: _entranceController,
                          child: GlassContainer(
                            opacity: 0.05,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: ZenTheme.softGold,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Bếp lửa sưởi ấm",
                                      style: textTheme.titleLarge!.copyWith(
                                        fontSize: 16,
                                        color: ZenTheme.softGold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "\"$_comfortQuote\"",
                                  style: textTheme.bodyLarge!.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    color: ZenTheme.creamWhite.withOpacity(
                                      0.85,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Vai trò: ${user?.spiritualRole.split(' ')[0] ?? 'Seeker'}",
                                      style: textTheme.bodyMedium!.copyWith(
                                        color: ZenTheme.sageGreen,
                                      ),
                                    ),
                                    Text(
                                      "Điểm thấu cảm: ${user?.empathyPoints ?? 0} EP",
                                      style: textTheme.bodyMedium!.copyWith(
                                        color: ZenTheme.softGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 8. Footer tagline
                        _StaggeredEntranceItem(
                          key: const ValueKey('entrance_8'),
                          index: 8,
                          controller: _entranceController,
                          child: Center(
                            child: Text(
                              "Anam • A Secular Sanctuary for Mindful Souls",
                              style: textTheme.bodyMedium!.copyWith(
                                fontSize: 11,
                                color: ZenTheme.softGray.withOpacity(0.5),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAnchorCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AnchorBloc, AnchorState>(
      builder: (context, state) {
        if (state is AnchorLoading) {
          return GlassContainer(
            opacity: 0.12,
            radius: 24,
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ZenTheme.sageGreen),
              ),
            ),
          );
        }

        AnchorModel? anchor;
        if (state is AnchorLoadSuccess) {
          anchor = state.anchor;
        } else if (state is AnchorSubmissionSuccess) {
          anchor = state.anchor;
        } else if (state is EveningReflectionSuccess) {
          anchor = state.anchor;
        }

        // Tình huống 1: Chưa hoàn thành Morning Anchor
        if (anchor == null || !anchor.morningCompleted) {
          return _buildMorningAnchorCard(context, textTheme);
        }

        // Tình huống 2: Đã xong Morning nhưng chưa xong Evening
        if (!anchor.eveningCompleted) {
          return _buildEveningReflectionCard(context, textTheme, anchor);
        }

        // Tình huống 3: Đã hoàn thành cả hai
        return _buildCompletedAnchorCard(context, textTheme, anchor);
      },
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
                      color: ZenTheme.sageGreen.withOpacity(0.15),
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
                            color: ZenTheme.sageGreen.withOpacity(0.8),
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
                      ZenTheme.sageGreen.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Gieo một ý niệm lành mạnh cho ngày hôm nay.",
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
                  color: ZenTheme.sageGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withOpacity(0.25),
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
                      color: eveningColor.withOpacity(0.15),
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
                          "Nhìn lại cuối ngày",
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
                            color: eveningColor.withOpacity(0.8),
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
                    colors: [eveningColor.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (anchor.intention.isNotEmpty) ...[
                Text(
                  "Sáng nay bạn đã đặt ý định:",
                  style: textTheme.bodyMedium!.copyWith(
                    color: ZenTheme.softGray.withOpacity(0.7),
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
                    color: ZenTheme.creamWhite.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ZenTheme.creamWhite.withOpacity(0.06),
                    ),
                  ),
                  child: Text(
                    "\"${anchor.intention}\"",
                    style: textTheme.bodyMedium!.copyWith(
                      color: ZenTheme.creamWhite.withOpacity(0.85),
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                "Dành vài phút nhìn lại để lòng thêm nhẹ nhõm trước khi ngủ.",
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
                  color: eveningColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eveningColor.withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bắt đầu nhìn lại tối",
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
                      color: completedColor.withOpacity(0.15),
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
                          "Khép lại ngày hôm nay",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Tâm trí đã sẵn sàng nghỉ ngơi",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 12,
                            color: completedColor.withOpacity(0.8),
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
                      completedColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tâm trí đã lắng yên. Bạn đã khép lại ngày hôm nay trọn vẹn.",
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
                  color: ZenTheme.sageGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Xem chi tiết ngày hôm nay",
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

  // Kết Nối & Nhìn Lại: Bếp lửa chung (trái) + Vườn Tâm Trí (phải)
  Widget _buildConnectionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryMenuCard(
            context: context,
            title: "Bếp lửa\nchung",
            icon: Icons.people_outline_outlined,
            color: ZenTheme.softGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HearthView()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecondaryMenuCard(
            context: context,
            title: "Vườn\nTâm Trí",
            icon: Icons.filter_vintage_outlined,
            color: ZenTheme.sageGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider<MindGardenBloc>(
                  create: (context) => MindGardenBloc(
                    databaseRepository:
                        RepositoryProvider.of<BaseDatabaseRepository>(context),
                  ),
                  child: const MindGardenScreen(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryMenuCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _PebblePressCard(
      onTap: onTap,
      child: GlassContainer(
        opacity: 0.07,
        radius: 26,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSilenceCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SilenceView()),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.inkBlue.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: ZenTheme.inkBlue,
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
                      "Khoảng lặng",
                      style: textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Hơi thở & tĩnh lặng nội tâm",
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: ZenTheme.creamWhite.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ZenTheme.inkBlue,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReleaseView()),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.mistRed.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.blur_on_outlined,
                  color: ZenTheme.mistRed,
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
                      "Khoảng buông",
                      style: textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Xả bỏ & giải phóng cảm xúc nặng nề",
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: ZenTheme.creamWhite.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ZenTheme.mistRed,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<ReflectionBloc>(
            create: (context) => ReflectionBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
            child: const ReflectionView(),
          ),
        ),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.softGold.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.visibility_outlined,
                  color: ZenTheme.softGold,
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
                      "Gương tự vấn",
                      style: textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Chiêm nghiệm & Đối thoại chiều sâu",
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: ZenTheme.creamWhite.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ZenTheme.softGold,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildGardenCard removed — Vườn Tâm Trí nay dùng _buildSecondaryMenuCard trong _buildConnectionRow
  // ignore: unused_element
  Widget _buildGardenCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<MindGardenBloc>(
            create: (context) => MindGardenBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
            child: const MindGardenScreen(),
          ),
        ),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.sageGreen.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.filter_vintage_outlined,
                  color: ZenTheme.sageGreen,
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
                      "Khu vườn tâm trí",
                      style: textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Lịch sử dấu ấn cảm xúc thiên nhiên",
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: ZenTheme.creamWhite.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ZenTheme.sageGreen,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepSeedCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SleepSeedScreen()),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 24,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZenTheme.sageGreen.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.spa_outlined,
                  color: ZenTheme.sageGreen,
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
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gieo mầm tĩnh tại trước giờ nghỉ ngơi",
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: ZenTheme.creamWhite.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ZenTheme.sageGreen,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
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
                    color: const Color(0xFF08080C).withOpacity(0.85),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: ZenTheme.sageGreen.withOpacity(0.05),
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
                            color: ZenTheme.sageGreen.withOpacity(0.12),
                            boxShadow: [
                              BoxShadow(
                                color: ZenTheme.sageGreen.withOpacity(0.2),
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
                          color: ZenTheme.softGray.withOpacity(0.8),
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
      paint.color = ZenTheme.softGold.withOpacity(opacity.clamp(0.0, 1.0));

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
