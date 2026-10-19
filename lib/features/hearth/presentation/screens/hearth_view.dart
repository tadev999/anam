import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/hearth_bloc.dart';
import '../../../release_space/data/models/release_model.dart';

class HearthView extends StatefulWidget {
  const HearthView({super.key});

  @override
  State<HearthView> createState() => _HearthViewState();
}

class _HearthViewState extends State<HearthView> {
  // Silent Presence Counter — số lượt hiện diện ẩn danh cạnh bếp lửa
  late int _silentPresenceCount;
  String _selectedFilter = 'all';

  static const List<Map<String, dynamic>> _filters = [
    {'id': 'all', 'label': 'Tất cả', 'icon': null},
    {'id': 'Lo âu & Kiệt sức', 'label': 'Kiệt sức & Lo âu', 'icon': '🌊'},
    {'id': 'Cô đơn & Kết nối', 'label': 'Cô đơn & Lạc lõng', 'icon': '🌙'},
    {'id': 'Áp lực thành tích', 'label': 'Áp lực & Kỳ vọng', 'icon': '🎓'},
    {'id': 'Giá trị bản thân', 'label': 'Giá trị bản thân', 'icon': '✨'},
    {'id': 'Buông bỏ', 'label': 'Buông bỏ', 'icon': '🍃'},
  ];

  @override
  void initState() {
    super.initState();
    // Tạo số người ngẫu nhiên từ seed theo giờ trong ngày
    final hour = DateTime.now().hour;
    _silentPresenceCount = 3 + ((hour * 7 + DateTime.now().minute ~/ 10) % 18);
    _loadReleases();
  }

  void _loadReleases() {
    BlocProvider.of<HearthBloc>(context).add(LoadReleasesRequested());
  }

  int _calculateRelevanceScore(String content, List<String> keywords) {
    final lowerContent = content.toLowerCase();
    int score = 0;
    for (final keyword in keywords) {
      if (lowerContent.contains(keyword.toLowerCase())) {
        score += 1;
      }
    }
    return score;
  }

  bool _matchesFilter(String content, String filterId) {
    if (filterId == 'all') return true;
    final config = _topicConfig[filterId];
    if (config == null) return true;
    final keywords = config['keywords'] as List<String>;
    final lower = content.toLowerCase();
    return keywords.any((kw) => lower.contains(kw));
  }

  void _sendHug(String releaseId) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final hearthBloc = BlocProvider.of<HearthBloc>(context);
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (sheetCtx) {
        return _EmpathyMirrorBottomSheet(
          releaseId: releaseId,
          senderUid: uid,
          hearthBloc: hearthBloc,
          authBloc: authBloc,
          dbRepo: dbRepo,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final user = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user
        : null;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Nền Zen sương khói
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZenTheme.slateDark, Color(0xff0e1318)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: BlocConsumer<HearthBloc, HearthState>(
              listener: (context, state) {
                if (state is HearthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ZenTheme.mistRed,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is HearthLoading;

                List<ReleaseModel> displayedReleases = [];
                if (state is HearthLoaded) {
                  final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(
                    context,
                  );
                  final mindState = dbRepo.currentMindState;

                  List<String> keywords = [];
                  if (mindState == 'lonely_state') {
                    keywords = [
                      'cô đơn',
                      'trống rỗng',
                      'lắng nghe',
                      'một mình',
                      'buồn',
                      'chia sẻ',
                    ];
                  } else if (mindState == 'burnout_state') {
                    keywords = [
                      'mệt',
                      'kiệt sức',
                      'áp lực',
                      'nghỉ ngơi',
                      'quá tải',
                      'stress',
                      'ngủ',
                    ];
                  } else if (mindState == 'overthinking_state') {
                    keywords = [
                      'suy nghĩ',
                      'lo âu',
                      'tha thứ',
                      'sợ',
                      'dũng cảm',
                      'sự thật',
                      'đúng sai',
                    ];
                  }

                  displayedReleases = List<ReleaseModel>.from(state.releases);
                  if (keywords.isNotEmpty) {
                    displayedReleases.sort((a, b) {
                      final scoreA = _calculateRelevanceScore(
                        a.content,
                        keywords,
                      );
                      final scoreB = _calculateRelevanceScore(
                        b.content,
                        keywords,
                      );
                      return scoreB.compareTo(scoreA);
                    });
                  }

                  if (_selectedFilter != 'all') {
                    displayedReleases = displayedReleases
                        .where((r) => _matchesFilter(r.content, _selectedFilter))
                        .toList();
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHearthHeader(context),
                    _buildHearthSanctuaryBanner(),
                    const SizedBox(height: 14),

                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Nỗi niềm quanh bếp",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (displayedReleases.isNotEmpty)
                            Text(
                              "${displayedReleases.length} chia sẻ",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: ZenTheme.softGray.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF9E79),
                              ),
                            )
                          : state is HearthLoaded && displayedReleases.isEmpty
                          ? _buildEmptyState(textTheme)
                          : state is HearthLoaded
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 6,
                              ),
                              itemCount: displayedReleases.length,
                              itemBuilder: (context, index) {
                                final release = displayedReleases[index];
                                final hasSupported = release.supportedUserUids
                                    .contains(user?.uid);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: hasSupported
                                          ? const Color(0xFFFF9E79).withValues(
                                              alpha: 0.35,
                                            )
                                          : AppColors.glassBorder,
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        release.content,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          height: 1.6,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      // Topic Tags tự động
                                      _buildTopicTags(
                                        release.content,
                                        textTheme,
                                      ),
                                      const SizedBox(height: 14),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 13,
                                                color: ZenTheme.softGray
                                                    .withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                _formatTimeAgo(release.timestamp),
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                  fontSize: 11.5,
                                                  color: ZenTheme.softGray
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),

                                          GestureDetector(
                                            onTap: hasSupported
                                                ? null
                                                : () => _sendHug(release.id),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 200,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 7,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: hasSupported
                                                    ? const Color(0xFFFF9E79)
                                                          .withValues(
                                                            alpha: 0.16,
                                                          )
                                                    : const Color(0xFFFF9E79)
                                                          .withValues(
                                                            alpha: 0.08,
                                                          ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: hasSupported
                                                      ? const Color(0xFFFF9E79)
                                                            .withValues(
                                                              alpha: 0.45,
                                                            )
                                                      : const Color(0xFFFF9E79)
                                                            .withValues(
                                                              alpha: 0.25,
                                                            ),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .local_fire_department_rounded,
                                                    color: Color(0xFFFF9E79),
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    hasSupported
                                                        ? "Đã sưởi ấm (${release.hugCount})"
                                                        : "Gửi hơi ấm (${release.hugCount})",
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: const Color(
                                                        0xFFFFB396,
                                                      ),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Topic Tags — Tự động phân loại nội dung theo chủ đề Endogenism
  // ---------------------------------------------------------------------------
  static const Map<String, Map<String, dynamic>> _topicConfig = {
    'Áp lực thành tích': {
      'keywords': [
        'thành công',
        'thất bại',
        'điểm',
        'bằng cấp',
        'thi',
        'áp lực',
        'cố gắng',
        'cạnh tranh',
      ],
      'icon': '🎓',
      'color': 0xffc98b8b,
    },
    'Lo âu & Kiệt sức': {
      'keywords': [
        'mệt',
        'kiệt sức',
        'stress',
        'lo',
        'sợ',
        'lo lắng',
        'burn out',
        'burnout',
      ],
      'icon': '🌊',
      'color': 0xff6a8caf,
    },
    'Cô đơn & Kết nối': {
      'keywords': [
        'cô đơn',
        'lạc lõng',
        'một mình',
        'không ai',
        'bạn bè',
        'gia đình',
        'yêu',
      ],
      'icon': '🌙',
      'color': 0xff8fa89b,
    },
    'Giá trị bản thân': {
      'keywords': [
        'giá trị',
        'xứng đáng',
        'tôi là',
        'bản thân',
        'không đủ',
        'kém',
        'tệ',
      ],
      'icon': '✨',
      'color': 0xffd4af37,
    },
    'Buông bỏ': {
      'keywords': [
        'buông',
        'tha thứ',
        'quá khứ',
        'không còn',
        'từ bỏ',
        'chấp nhận',
      ],
      'icon': '🍃',
      'color': 0xffb5c7be,
    },
  };

  Widget _buildTopicTags(String content, TextTheme textTheme) {
    final lowerContent = content.toLowerCase();
    final matchedTopics = <Map<String, dynamic>>[];

    _topicConfig.forEach((topic, config) {
      final keywords = config['keywords'] as List<String>;
      final matched = keywords.any((kw) => lowerContent.contains(kw));
      if (matched) matchedTopics.add({'name': topic, ...config});
    });

    if (matchedTopics.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: matchedTopics.take(2).map((topic) {
        final color = Color(topic['color'] as int);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topic['icon'] as String,
                style: const TextStyle(fontSize: 10),
              ),
              const SizedBox(width: 4),
              Text(
                topic['name'] as String,
                style: textTheme.bodyMedium!.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHearthHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tầng 1: Eyebrow row (Tag pill bên trái + Presence badge bên phải)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9E79).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF9E79).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFFF9E79),
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "BẾP LỬA THẤU CẢM",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: const Color(0xFFFF9E79),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🕯️', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      '$_silentPresenceCount cùng ngồi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Tầng 2: Title lớn
          Text(
            "Ngồi Lại Bên Nhau",
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
            "Nơi những tâm hồn đồng điệu cùng sưởi ấm cho nhau qua những dòng sẻ chia ẩn danh.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHearthSanctuaryBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9E79).withValues(alpha: 0.12),
            ZenTheme.softGold.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFF9E79).withValues(alpha: 0.22),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF9E79).withValues(alpha: 0.15),
              border: Border.all(
                color: const Color(0xFFFF9E79).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFF9E79),
              size: 22,
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
                      "Hơi Ấm Tự Thân",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: ZenTheme.creamWhite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ZenTheme.softGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Bình đẳng & Vô điều kiện",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: ZenTheme.softGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Trước bếp lửa, mọi nỗi niềm đều xứng đáng được lắng nghe trong tĩnh lặng.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: ZenTheme.softGray,
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['id'];
          final icon = filter['icon'] as String?;
          final label = filter['label'] as String;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter['id'] as String;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF9E79).withValues(alpha: 0.18)
                    : AppColors.surfaceLight.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF9E79).withValues(alpha: 0.5)
                      : AppColors.glassBorder,
                  width: isSelected ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Text(icon, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFFFB396)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    final isFiltered = _selectedFilter != 'all';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9E79).withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF9E79),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? "Chưa có chia sẻ nào về chủ đề này"
                  : "Bếp lửa chung hiện rất bình yên",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ZenTheme.creamWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? "Hãy thử chọn một chủ đề khác hoặc lắng nghe những dòng sẻ chia khác quanh bếp lửa."
                  : "Chưa có nỗi niềm nào cần được sưởi ấm lúc này.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: ZenTheme.softGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} phút trước";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} giờ trước";
    } else {
      return "${diff.inDays} ngày trước";
    }
  }
}

class _EmpathyMirrorBottomSheet extends StatefulWidget {
  final String releaseId;
  final String senderUid;
  final HearthBloc hearthBloc;
  final AuthBloc authBloc;
  final BaseDatabaseRepository dbRepo;

  const _EmpathyMirrorBottomSheet({
    required this.releaseId,
    required this.senderUid,
    required this.hearthBloc,
    required this.authBloc,
    required this.dbRepo,
  });

  @override
  State<_EmpathyMirrorBottomSheet> createState() =>
      _EmpathyMirrorBottomSheetState();
}

class _EmpathyMirrorBottomSheetState extends State<_EmpathyMirrorBottomSheet>
    with SingleTickerProviderStateMixin {
  String? _selectedChipId;
  bool _isSuccess = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _heartScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_selectedChipId == null) return;

    // 1. Update currentMindState
    if (_selectedChipId == 'resonance') {
      widget.dbRepo.currentMindState = 'lonely_state';
    } else if (_selectedChipId == 'need') {
      widget.dbRepo.currentMindState = 'burnout_state';
    } else if (_selectedChipId == 'truth') {
      widget.dbRepo.currentMindState = 'overthinking_state';
    }

    // 2. Trigger SendHugRequested in HearthBloc
    widget.hearthBloc.add(SendHugRequested(widget.releaseId, widget.senderUid));

    // 3. Award +3 EP in AuthBloc
    widget.authBloc.add(const EmpathyPointsUpdated(3));

    // 4. Set Success and start heart animation
    setState(() {
      _isSuccess = true;
    });
    _heartController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isSuccess,
      child: GlassContainer(
        opacity: 0.08,
        radius: 32,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSuccess
              ? _buildSuccessContent(textTheme)
              : _buildSelectionContent(textTheme),
        ),
      ),
    );
  }

  Widget _buildSelectionContent(TextTheme textTheme) {
    return Column(
      key: const ValueKey('selection'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ZenTheme.creamWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Gương thấu cảm",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFF9E79),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            "Chia sẻ này chạm vào nhu cầu nào của bạn lúc này?",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3 Reflection Chips
        _buildReflectionOption(
          id: 'resonance',
          label: "Tôi cũng từng trải qua điều tương tự",
          accentColor: ZenTheme.sageGreen,
        ),
        const SizedBox(height: 12),
        _buildReflectionOption(
          id: 'need',
          label: "Tôi muốn sưởi ấm vì tôi cũng cần sự ấm áp",
          accentColor: const Color(0xFFFF9E79),
        ),
        const SizedBox(height: 12),
        _buildReflectionOption(
          id: 'truth',
          label: "Tôi trân trọng sự dũng cảm nói ra sự thật",
          accentColor: ZenTheme.softGold,
        ),
        const SizedBox(height: 24),

        Opacity(
          opacity: _selectedChipId != null ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: _selectedChipId == null,
            child: ZenButton(
              text: "Gửi hơi ấm thấu cảm",
              onPressed: _onConfirm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionOption({
    required String id,
    required String label,
    required Color accentColor,
  }) {
    final isSelected = _selectedChipId == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChipId = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : ZenTheme.creamWhite.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : ZenTheme.creamWhite.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : ZenTheme.softGray.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? accentColor : ZenTheme.softGray,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(TextTheme textTheme) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 28),
        Center(
          child: ScaleTransition(
            scale: _heartScale,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF9E79).withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9E79).withValues(alpha: 0.25),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF9E79),
                size: 48,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Hơi ấm đã được trao gửi",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ZenTheme.creamWhite,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Sự hiện diện thấu cảm của bạn đã lặng lẽ sưởi ấm một tâm hồn đồng điệu.\nCảm ơn bạn vì đã cùng giữ cho bếp lửa đêm nay luôn ấm.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: ZenTheme.softGray,
                fontSize: 13.5,
                height: 1.6,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        ZenButton(
          text: "Khép lại & Trở về bếp lửa",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
