import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../daily_ritual/presentation/screens/ritual_view.dart';
import '../../../confessional/presentation/screens/confessional_view.dart';
import '../../../tribe/presentation/screens/tribe_view.dart';
import '../../../monastery/presentation/screens/monastery_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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

          SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = (state is Authenticated) ? state.user : null;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
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
                              "\"Hôm nay, dù thế giới ngoài kia có xô bồ và lạnh lẽo thế nào, hãy nhớ rằng bạn luôn có một chốn nương tựa ở đây. Bạn hoàn hảo theo cách của riêng mình.\"",
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
                      const SizedBox(height: 32),

                      Text(
                        "Nghi lễ Mỗi Ngày",
                        style: textTheme.displaySmall!.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "Bắt đầu nghi lễ chính với trải nghiệm nhẹ nhàng, ít nhiễu và dễ tiếp cận.",
                        style: textTheme.bodyLarge!.copyWith(
                          fontSize: 15,
                          color: ZenTheme.creamWhite.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMainRitualCard(context),
                      const SizedBox(height: 24),
                      _buildSecondaryMenuRow(context),
                      const SizedBox(height: 30),

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

  Widget _buildMainRitualCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RitualView()),
      ),
      child: GlassContainer(
        opacity: 0.12,
        radius: 38,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ZenTheme.sageGreen.withOpacity(0.14),
                    ),
                    child: const Icon(
                      Icons.brightness_6_outlined,
                      color: ZenTheme.sageGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Nghi lễ Mỗi Ngày",
                    style: textTheme.headlineSmall!.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ZenTheme.creamWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                "Bắt đầu nghi lễ chính, giữ tâm trí nhẹ nhàng và tập trung ngay từ khi mở app.",
                style: textTheme.bodyLarge!.copyWith(
                  fontSize: 15,
                  color: ZenTheme.creamWhite.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.sageGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bắt đầu",
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ZenTheme.sageGreen,
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
            title: "Phòng Xưng tội",
            icon: Icons.blur_on_outlined,
            color: ZenTheme.mistRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfessionalView()),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSecondaryMenuCard(
            context: context,
            title: "Bộ lạc",
            icon: Icons.people_outline_outlined,
            color: ZenTheme.softGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TribeView()),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildSecondaryMenuCard(
            context: context,
            title: "Tu viện",
            icon: Icons.spa_outlined,
            color: ZenTheme.inkBlue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonasteryView()),
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
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: 0.08,
        radius: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
