import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../daily_anchor/presentation/screens/anchor_view.dart';
import '../../../release_space/presentation/screens/release_view.dart';
import '../../../hearth/presentation/screens/hearth_view.dart';
import '../../../silence/presentation/screens/silence_view.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final String _comfortQuote;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _comfortQuote = ZenConstants.hearthQuotes[random.nextInt(ZenConstants.hearthQuotes.length)];
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

          // Đốm sáng Bếp Lửa nhấp nháy mờ nhẹ góc dưới
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZenTheme.softGold.withOpacity(0.04),
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
                color: ZenTheme.sageGreen.withOpacity(0.03),
              ),
            ),
          ),

          SafeArea(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chào bạn đồng hành,",
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
                              _buildStreakBadge(context, user?.streak ?? 0),
                              const SizedBox(width: 12),
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
                      const SizedBox(height: 28),

                      // Lời Chào "Bếp Lửa" (The Hearth Card)
                      GlassContainer(
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
                                color: ZenTheme.creamWhite.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      const SizedBox(height: 36),

                      // Label phần chính
                      Text(
                        "Điểm neo Mỗi Ngày",
                        style: textTheme.displaySmall!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ZenTheme.sageGreen,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Hero Card — Primary, nổi bật nhất
                      _buildMainAnchorCard(context),
                      const SizedBox(height: 32),

                      // Tự Thấu Hiểu (Gương Tự Vấn)
                      Text(
                        "Tự Thấu Hiểu",
                        style: textTheme.displaySmall!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ZenTheme.softGold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildReflectionCard(context),
                      const SizedBox(height: 32),

                      // Label phần phụ
                      Text(
                        "Khám phá thêm",
                        style: textTheme.bodyMedium!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ZenTheme.softGray.withOpacity(0.6),
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSecondaryMenuRow(context),
                      const SizedBox(height: 40),

                      // Châm ngôn chân lý Stoic ở cuối
                      Center(
                        child: Text(
                          "Anam • A Secular Sanctuary for Mindful Souls",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 11,
                            color: ZenTheme.softGray.withOpacity(0.5),
                            letterSpacing: 1.5,
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
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ZenTheme.sageGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ZenTheme.sageGreen.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            color: ZenTheme.sageGreen,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            "$streak ngày thiền",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: ZenTheme.sageGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAnchorCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnchorView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 38,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge chính
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.sageGreen.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.brightness_6_outlined,
                      color: ZenTheme.sageGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Điểm neo Mỗi Ngày",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hành động chính của hôm nay",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 13,
                            color: ZenTheme.sageGreen.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider tinh tế
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
              const SizedBox(height: 20),

              Text(
                "Bắt đầu điểm neo chính, giữ tâm trí nhẹ nhàng và tập trung ngay từ khi mở app.",
                style: textTheme.bodyLarge!.copyWith(
                  fontSize: 15,
                  color: ZenTheme.creamWhite.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // CTA Button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.sageGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: ZenTheme.sageGreen.withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bắt đầu điểm neo",
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.sageGreen,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: ZenTheme.sageGreen,
                      size: 20,
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

  Widget _buildSecondaryMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildSecondaryMenuCard(
            context: context,
            title: "Khoảng\nBuông",
            icon: Icons.blur_on_outlined,
            color: ZenTheme.mistRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReleaseView()),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
            title: "Khoảng\nlặng",
            icon: Icons.spa_outlined,
            color: ZenTheme.inkBlue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SilenceView()),
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

  Widget _buildReflectionCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return _PebblePressCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider<ReflectionBloc>(
            create: (context) => ReflectionBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(context),
            ),
            child: const ReflectionView(),
          ),
        ),
      ),
      child: GlassContainer(
        opacity: 0.08,
        radius: 38,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.softGold.withOpacity(0.12),
                    ),
                    child: const Icon(
                      Icons.visibility_outlined,
                      color: ZenTheme.softGold,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gương Tự Vấn",
                          style: textTheme.headlineSmall!.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ZenTheme.creamWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Đối thoại chiều sâu với bản thân",
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: 13,
                            color: ZenTheme.softGold.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ZenTheme.softGold.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Dành 5 phút tự vấn trước những câu hỏi mở của triết học Nội Sinh, xua tan sương mù trong tâm trí.",
                style: textTheme.bodyLarge!.copyWith(
                  fontSize: 15,
                  color: ZenTheme.creamWhite.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.softGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: ZenTheme.softGold.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Mở gương tự vấn",
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.softGold,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: ZenTheme.softGold,
                      size: 20,
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
}

class _PebblePressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PebblePressCard({
    required this.child,
    required this.onTap,
  });

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
