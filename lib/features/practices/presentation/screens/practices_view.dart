import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../silence/presentation/screens/silence_view.dart';
import '../../../release_space/presentation/screens/release_view.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';
import '../../../sleep_seed/presentation/screens/sleep_seed_screen.dart';

class PracticesView extends StatelessWidget {
  const PracticesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Nền Dark Luxury
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

          // Đốm sáng radar mờ nhẹ
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.radarActive.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    "KHÔNG GIAN LẮNG DỊU",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Các bài thực tập tự thân",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Nơi bạn dừng chân, ngắt kết nối với thế giới ồn ào và trở về làm bạn với chính mình.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Practice 1: Khoảng Lặng
                  _buildPracticeCard(
                    context: context,
                    title: "Khoảng Lặng",
                    subtitle: "Thở định tâm & chuông chánh niệm thanh lọc tâm trí",
                    tag: "Định tâm • 3-10 phút",
                    icon: Icons.spa_rounded,
                    color: AppColors.radarActive,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SilenceView()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Practice 2: Khoảng Buông
                  _buildPracticeCard(
                    context: context,
                    title: "Khoảng Buông",
                    subtitle: "Viết ra những nỗi niềm nặng nề và để chúng tan vào hư vô",
                    tag: "Xả bỏ • 3 phút",
                    icon: Icons.cloud_queue_rounded,
                    color: AppColors.accentRose,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReleaseView()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Practice 3: Gương Tự Vấn
                  _buildPracticeCard(
                    context: context,
                    title: "Gương Tự Vấn",
                    subtitle: "Đối thoại sâu sắc qua những câu hỏi soi chiếu nội tâm",
                    tag: "Thấu hiểu • 5 phút",
                    icon: Icons.psychology_rounded,
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<ReflectionBloc>(
                          create: (ctx) => ReflectionBloc(
                            databaseRepository:
                                RepositoryProvider.of<BaseDatabaseRepository>(ctx),
                          ),
                          child: const ReflectionView(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Practice 4: Hạt Mầm Giấc Ngủ
                  _buildPracticeCard(
                    context: context,
                    title: "Hạt Mầm Giấc Ngủ",
                    subtitle: "Gieo một ý niệm bình yên trước khi ngủ để hồi phục qua đêm",
                    tag: "Tái tạo • Đêm khuya",
                    icon: Icons.bedtime_rounded,
                    color: const Color(0xFF8B7CF8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SleepSeedScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Wisdom section
                  Text(
                    "TRI THỨC NỘI SINH",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWisdomPreview(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWisdomPreview(BuildContext context) {
    final flashcards = ZenConstants.wisdomFlashcards;
    final card = flashcards.isNotEmpty ? flashcards.first : null;

    if (card == null) return const SizedBox.shrink();

    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.gold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Góc nhìn hôm nay",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "\"${card['quote']}\"",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card['question'] as String? ?? '',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
