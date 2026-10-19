import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../silence/presentation/screens/silence_view.dart';
import '../../../release_space/presentation/screens/release_view.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';

class PracticesView extends StatefulWidget {
  const PracticesView({super.key});

  @override
  State<PracticesView> createState() => _PracticesViewState();
}

class _SoundscapeItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String assetPath;

  const _SoundscapeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.assetPath,
  });
}

class _PracticesViewState extends State<PracticesView> {
  late final AudioPlayer _audioPlayer;
  String? _activeSoundId;
  bool _isPlayingSound = false;

  static const List<_SoundscapeItem> _soundscapes = [
    _SoundscapeItem(
      id: 'rain',
      title: 'Mưa êm đềm',
      subtitle: 'Mưa rơi mái hiên',
      icon: Icons.water_drop_outlined,
      assetPath: 'assets/audio/rain_sleep.m4a',
    ),
    _SoundscapeItem(
      id: 'stream',
      title: 'Suối rừng sâu',
      subtitle: 'Nước chảy róc rách',
      icon: Icons.waves_outlined,
      assetPath: 'assets/audio/stream.m4a',
    ),
    _SoundscapeItem(
      id: 'fire',
      title: 'Bếp lửa đêm',
      subtitle: 'Củi reo tí tách',
      icon: Icons.local_fire_department_outlined,
      assetPath: 'assets/audio/fire.m4a',
    ),
    _SoundscapeItem(
      id: 'waves',
      title: 'Sóng biển biếc',
      subtitle: 'Nhịp sóng vỗ bờ',
      icon: Icons.tsunami_outlined,
      assetPath: 'assets/audio/waves.m4a',
    ),
    _SoundscapeItem(
      id: 'wind',
      title: 'Gió đại ngàn',
      subtitle: 'Gió luồn rừng thông',
      icon: Icons.air_outlined,
      assetPath: 'assets/audio/wind.m4a',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _listenToPlayerState();
  }

  void _listenToPlayerState() {
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingSound = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSound(_SoundscapeItem item) async {
    HapticFeedback.selectionClick();
    if (_activeSoundId == item.id && _isPlayingSound) {
      await _stopSound();
    } else {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setAsset(item.assetPath);
        await _audioPlayer.setLoopMode(LoopMode.one);
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play();
        if (mounted) {
          setState(() {
            _activeSoundId = item.id;
            _isPlayingSound = true;
          });
        }
      } catch (e) {
        debugPrint('Soundscape play error: $e');
      }
    }
  }

  Future<void> _stopSound() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _activeSoundId = null;
        _isPlayingSound = false;
      });
    }
  }

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

          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header: Thánh đường thế tục
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // 2. Định hướng theo trạng thái cảm xúc (State-Based Guidance)
                  _buildEmotionalPromptHeader(),
                  const SizedBox(height: 14),

                  // 3. Ba cánh cửa thực hành tâm lý cốt lõi
                  // Cửa 1: Lắng Đọng (Khoảng Lặng)
                  _buildStatePracticeCard(
                    context: context,
                    stateLabel: "LẮNG ĐỌNG",
                    title: "Khoảng Lặng",
                    subtitle: "Theo dõi hơi thở & chuông chánh niệm để đưa tâm trí về trạng thái phẳng lặng",
                    tag: "Định tâm • 3-10 phút",
                    icon: Icons.spa_rounded,
                    accentColor: AppColors.radarActive,
                    badgeBg: AppColors.radarActive.withValues(alpha: 0.12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SilenceView()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cửa 2: Buông Xả (Khoảng Buông)
                  _buildStatePracticeCard(
                    context: context,
                    stateLabel: "BUÔNG XẢ",
                    title: "Khoảng Buông",
                    subtitle: "Viết ra những nỗi niềm nặng trĩu và để chúng tan biến nhẹ nhàng vào hư không",
                    tag: "Nhẹ lòng • 3 phút",
                    icon: Icons.cloud_queue_rounded,
                    accentColor: AppColors.accentRose,
                    badgeBg: AppColors.accentRose.withValues(alpha: 0.12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReleaseView()),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cửa 3: Thấu Suốt (Gương Tự Vấn)
                  _buildStatePracticeCard(
                    context: context,
                    stateLabel: "THẤU SUỐT",
                    title: "Gương Tự Vấn",
                    subtitle: "Lắng nghe và đối thoại trung thực với chính mình qua những câu hỏi tự soi chiếu",
                    tag: "Sáng tỏ • 5 Mạch Endo",
                    icon: Icons.psychology_rounded,
                    accentColor: AppColors.secondary,
                    badgeBg: AppColors.secondary.withValues(alpha: 0.12),
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
                  const SizedBox(height: 28),

                  // 4. Âm Thanh Tĩnh Lặng (Ambient Soundscapes)
                  _buildSoundscapesSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget Components
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    Icons.self_improvement_rounded,
                    color: AppColors.primary,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "KHÔNG GIAN LẮNG DỊU",
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
                "Chậm lại một nhịp",
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
        Text(
          "Trở Về Với Chính Mình",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Nơi bạn ngắt kết nối với thế giới vội vã, hạ nhiệt hệ thần kinh và làm bạn với tâm trí.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalPromptHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.spa_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Một chốn dừng chân dịu lành cho tâm trí bạn",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePracticeCard({
    required BuildContext context,
    required String stateLabel,
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color accentColor,
    required Color badgeBg,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: accentColor.withValues(alpha: 0.12),
          highlightColor: accentColor.withValues(alpha: 0.06),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon tròn bên trái
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 15),

                // Nội dung chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip trạng thái cảm xúc
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              stateLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: accentColor,
                              ),
                            ),
                          ),
                          Text(
                            tag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
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
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.textMuted,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Âm Thanh Tĩnh Lặng (Ambient Soundscapes)
  // ---------------------------------------------------------------------------
  Widget _buildSoundscapesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.graphic_eq_rounded,
              color: AppColors.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "ÂM THANH TĨNH LẶNG",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            if (_isPlayingSound)
              GestureDetector(
                onTap: _stopSound,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentRose.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.accentRose.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stop_rounded,
                        color: AppColors.accentRose,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Dừng phát",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentRose,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Không gian âm thanh tự nhiên giúp hạ kích thích giác quan & tập trung sâu.",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Carousel ngang các âm thanh
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _soundscapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _soundscapes[index];
              final isActive = _activeSoundId == item.id && _isPlayingSound;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 136,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.glassBorder,
                    width: isActive ? 1.4 : 1,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _toggleSound(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.primary.withValues(alpha: 0.12),
                                ),
                                child: Icon(
                                  isActive
                                      ? Icons.volume_up_rounded
                                      : item.icon,
                                  color: isActive
                                      ? Colors.black87
                                      : AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isActive
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_outline_rounded,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w600,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
