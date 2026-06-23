import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../bloc/hearth_bloc.dart';
import '../../../release_space/data/models/release_model.dart';

class HearthView extends StatefulWidget {
  const HearthView({super.key});

  @override
  State<HearthView> createState() => _HearthViewState();
}

class _HearthViewState extends State<HearthView> {
  @override
  void initState() {
    super.initState();
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
      barrierColor: Colors.black.withOpacity(0.5),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ZenTheme.creamWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bếp Lửa Chung",
          style: textTheme.titleLarge!.copyWith(fontFamily: 'Lora', fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
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
                    SnackBar(content: Text(state.message), backgroundColor: ZenTheme.mistRed),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is HearthLoading;

                List<ReleaseModel> displayedReleases = [];
                if (state is HearthLoaded) {
                  final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
                  final mindState = dbRepo.currentMindState;

                  List<String> keywords = [];
                  if (mindState == 'lonely_state') {
                    keywords = ['cô đơn', 'trống rỗng', 'lắng nghe', 'một mình', 'buồn', 'chia sẻ'];
                  } else if (mindState == 'burnout_state') {
                    keywords = ['mệt', 'kiệt sức', 'áp lực', 'nghỉ ngơi', 'quá tải', 'stress', 'ngủ'];
                  } else if (mindState == 'overthinking_state') {
                    keywords = ['suy nghĩ', 'lo âu', 'tha thứ', 'sợ', 'dũng cảm', 'sự thật', 'đúng sai'];
                  }

                  displayedReleases = List<ReleaseModel>.from(state.releases);
                  if (keywords.isNotEmpty) {
                    displayedReleases.sort((a, b) {
                      final scoreA = _calculateRelevanceScore(a.content, keywords);
                      final scoreB = _calculateRelevanceScore(b.content, keywords);
                      return scoreB.compareTo(scoreA); // Descending order of relevance
                    });
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmpathySummary(textTheme, user),
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Hãy sưởi ấm những nỗi lòng xung quanh",
                        style: textTheme.titleLarge!.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: ZenTheme.sageGreen))
                          : state is HearthLoaded && displayedReleases.isEmpty
                              ? _buildEmptyState(textTheme)
                              : state is HearthLoaded
                                  ? ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      itemCount: displayedReleases.length,
                                      itemBuilder: (context, index) {
                                        final release = displayedReleases[index];
                                        final hasSupported = release.supportedUserUids.contains(user?.uid);
                                        
                                        return GlassContainer(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          opacity: 0.04,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                release.content,
                                                style: textTheme.bodyLarge!.copyWith(
                                                  fontSize: 14,
                                                  height: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatTimeAgo(release.timestamp),
                                                    style: textTheme.bodyMedium!.copyWith(
                                                      fontSize: 11,
                                                      color: ZenTheme.softGray.withOpacity(0.5),
                                                    ),
                                                  ),
                                                  
                                                  GestureDetector(
                                                    onTap: hasSupported ? null : () => _sendHug(release.id),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: hasSupported
                                                            ? ZenTheme.sageGreen.withOpacity(0.12)
                                                            : ZenTheme.softGold.withOpacity(0.08),
                                                        borderRadius: BorderRadius.circular(20),
                                                        border: Border.all(
                                                          color: hasSupported
                                                              ? ZenTheme.sageGreen.withOpacity(0.2)
                                                              : ZenTheme.softGold.withOpacity(0.2),
                                                          width: 1.0,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            hasSupported ? Icons.favorite : Icons.favorite_border,
                                                            color: hasSupported ? ZenTheme.sageGreen : ZenTheme.softGold,
                                                            size: 14,
                                                          ),
                                                          const SizedBox(width: 6),
                                                          Text(
                                                            hasSupported
                                                                ? "Đã sưởi ấm (${release.hugCount})"
                                                                : "Sưởi ấm (${release.hugCount})",
                                                            style: TextStyle(
                                                              color: hasSupported ? ZenTheme.sageGreen : ZenTheme.softGold,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
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

  Widget _buildEmpathySummary(TextTheme textTheme, UserModel? user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ZenTheme.sageGreen.withOpacity(0.08),
            ZenTheme.softGold.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZenTheme.sageGreen.withOpacity(0.15),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZenTheme.sageGreen.withOpacity(0.1),
            ),
            child: const Icon(Icons.people_outline, color: ZenTheme.sageGreen, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.spiritualRole ?? "Seeker (Người tìm kiếm)",
                  style: textTheme.titleLarge!.copyWith(fontSize: 16, color: ZenTheme.creamWhite),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tích luỹ 50 EP để nâng mức độ thấu cảm, lan tỏa hơi ấm đến mọi người.",
                  style: textTheme.bodyMedium!.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 10),
                _buildProgressLinear(user?.empathyPoints ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLinear(int points) {
    final double percent = (points / 50).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: const AlwaysStoppedAnimation<Color>(ZenTheme.softGold),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$points EP", style: const TextStyle(color: ZenTheme.softGold, fontSize: 10)),
            const Text("50 EP", style: TextStyle(color: ZenTheme.softGray, fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_cloudy_outlined, color: ZenTheme.softGray, size: 48),
          const SizedBox(height: 16),
          Text("Bếp lửa chung hiện rất bình yên", style: textTheme.titleLarge!.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          const Text("Chưa có chia sẻ nào cần được sưởi ấm.", style: TextStyle(color: ZenTheme.softGray)),
        ],
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
    super.key,
    required this.releaseId,
    required this.senderUid,
    required this.hearthBloc,
    required this.authBloc,
    required this.dbRepo,
  });

  @override
  State<_EmpathyMirrorBottomSheet> createState() => _EmpathyMirrorBottomSheetState();
}

class _EmpathyMirrorBottomSheetState extends State<_EmpathyMirrorBottomSheet> with SingleTickerProviderStateMixin {
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
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeInOut));
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
              color: ZenTheme.creamWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Gương Thấu Cảm",
            style: textTheme.titleLarge!.copyWith(
              fontFamily: 'Lora',
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: ZenTheme.softGold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            "Chia sẻ này chạm vào nhu cầu nào của bạn lúc này?",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge!.copyWith(
              color: ZenTheme.creamWhite.withOpacity(0.8),
              fontSize: 13,
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
          accentColor: ZenTheme.inkBlue,
        ),
        const SizedBox(height: 12),
        _buildReflectionOption(
          id: 'truth',
          label: "Tôi trân trọng sự dũng cảm nói ra sự thật",
          accentColor: ZenTheme.mistRed,
        ),
        const SizedBox(height: 24),

        Opacity(
          opacity: _selectedChipId != null ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: _selectedChipId == null,
            child: ZenButton(
              text: "Gửi hơi ấm & Phản chiếu",
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
              ? accentColor.withOpacity(0.12)
              : ZenTheme.creamWhite.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? accentColor.withOpacity(0.5)
                : ZenTheme.creamWhite.withOpacity(0.08),
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
                  color: isSelected ? accentColor : ZenTheme.softGray.withOpacity(0.6),
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
                style: TextStyle(
                  color: isSelected ? accentColor : ZenTheme.softGray,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        const SizedBox(height: 32),
        Center(
          child: ScaleTransition(
            scale: _heartScale,
            child: const Icon(
              Icons.favorite,
              color: ZenTheme.mistRed,
              size: 64,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            "Đã Phản Chiếu Cảm Xúc",
            style: textTheme.titleLarge!.copyWith(
              fontFamily: 'Lora',
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: ZenTheme.creamWhite,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Hơi ấm đã được gửi đi thành công. Trải nghiệm thấu cảm này giúp bạn tích luỹ +3 EP để hiểu sâu hơn về bản thân.",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge!.copyWith(
                color: ZenTheme.softGray,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ZenButton(
          text: "Khép lại gương",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
