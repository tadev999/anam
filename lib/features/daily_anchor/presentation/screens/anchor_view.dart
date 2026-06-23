import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/anchor_bloc.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';

// ---------------------------------------------------------------------------
// Model dữ liệu cảm xúc — Emotion Check-In
// ---------------------------------------------------------------------------
class _EmotionOption {
  final String id;
  final String label;
  final String emoji;
  final Color accentColor;

  const _EmotionOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.accentColor,
  });
}

const List<_EmotionOption> _emotionOptions = [
  _EmotionOption(
    id: 'burnout',
    label: 'Kiệt sức',
    emoji: '🔥',
    accentColor: ZenTheme.mistRed,
  ),
  _EmotionOption(
    id: 'overthinking',
    label: 'Đang suy nghĩ nhiều',
    emoji: '🌀',
    accentColor: ZenTheme.inkBlue,
  ),
  _EmotionOption(
    id: 'lonely',
    label: 'Cô đơn',
    emoji: '🌑',
    accentColor: ZenTheme.softGray,
  ),
  _EmotionOption(
    id: 'empty',
    label: 'Trống rỗng',
    emoji: '🫧',
    accentColor: ZenTheme.creamWhite,
  ),
  _EmotionOption(
    id: 'peaceful',
    label: 'Bình yên hôm nay',
    emoji: '☀️',
    accentColor: ZenTheme.sageGreen,
  ),
];

// ---------------------------------------------------------------------------
// Màn hình chính
// ---------------------------------------------------------------------------
class AnchorView extends StatefulWidget {
  const AnchorView({super.key});

  @override
  State<AnchorView> createState() => _AnchorViewState();
}

class _AnchorViewState extends State<AnchorView> {
  // step -1: Check-In cảm xúc
  // step  0: Affirmation (cá nhân hóa)
  // step  1: Micro-Offering
  // step  2: Intention
  // step  3: Hoàn thành
  int _currentStep = -1;

  String? _selectedEmotionId;
  late String _selectedAffirmation;
  String? _selectedOfferingId;
  final _intentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Read local cross-feature emotional loop state
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
    final mindState = dbRepo.currentMindState;
    if (mindState != null) {
      String? emotionId;
      if (mindState == 'burnout_state') {
        emotionId = 'burnout';
      } else if (mindState == 'overthinking_state') {
        emotionId = 'overthinking';
      } else if (mindState == 'lonely_state') {
        emotionId = 'lonely';
      } else if (mindState == 'peaceful_state') {
        emotionId = 'peaceful';
      }

      if (emotionId != null) {
        _selectedEmotionId = emotionId;
        _currentStep = 0; // Skip check-in step (-1) and go straight to Affirmation step (0)
        _selectedAffirmation = _pickRandomAffirmation(emotionId);
      } else {
        _selectedAffirmation = _pickRandomAffirmation(null);
      }
    } else {
      _selectedAffirmation = _pickRandomAffirmation(null);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayAnchor();
    });
  }

  // Chọn affirmation ngẫu nhiên từ đúng nhóm cảm xúc
  String _pickRandomAffirmation(String? emotionId) {
    final rand = Random();
    if (emotionId != null &&
        ZenConstants.emotionalAffirmations.containsKey(emotionId)) {
      final group = ZenConstants.emotionalAffirmations[emotionId]!;
      return group[rand.nextInt(group.length)];
    }
    // Fallback: random toàn bộ pool (tương thích ngược)
    return ZenConstants.dailyAffirmations[
        rand.nextInt(ZenConstants.dailyAffirmations.length)];
  }

  void _checkTodayAnchor() {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final anchorBloc = BlocProvider.of<AnchorBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';
    anchorBloc.add(CheckTodayAnchorRequested(uid, _getTodayString()));
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _onEmotionSelected(String emotionId) {
    setState(() {
      _selectedEmotionId = emotionId;
      // Re-generate affirmation setiap kali emosi berubah
      _selectedAffirmation = _pickRandomAffirmation(emotionId);
    });
    // Update cross-feature loop state
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
    if (emotionId == 'burnout') {
      dbRepo.currentMindState = 'burnout_state';
    } else if (emotionId == 'overthinking') {
      dbRepo.currentMindState = 'overthinking_state';
    } else if (emotionId == 'lonely') {
      dbRepo.currentMindState = 'lonely_state';
    } else if (emotionId == 'empty') {
      dbRepo.currentMindState = 'lonely_state';
    } else if (emotionId == 'peaceful') {
      dbRepo.currentMindState = 'peaceful_state';
    }
  }

  void _finishAnchor() {
    if (_intentionController.text.trim().isEmpty) return;

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final anchorBloc = BlocProvider.of<AnchorBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';

    anchorBloc.add(CompleteTodayAnchorRequested(
      uid: uid,
      date: _getTodayString(),
      affirmation: _selectedAffirmation,
      microOfferingId: _selectedOfferingId ?? 'water',
      intention: _intentionController.text.trim(),
      emotionCheckIn: _selectedEmotionId,
    ));
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: ZenTheme.creamWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điểm Neo Mỗi Ngày',
          style: textTheme.titleLarge!
              .copyWith(fontFamily: 'Lora', fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [ZenTheme.slateDark, Color(0xff0f1419)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: BlocConsumer<AnchorBloc, AnchorState>(
              listener: (context, state) {
                // Nếu điểm neo hôm nay đã completed → bỏ qua Check-In, hiện Completed
                if (state is AnchorLoadSuccess &&
                    state.anchor != null &&
                    state.anchor!.completed) {
                  setState(() {
                    _currentStep = 3;
                    _selectedAffirmation = state.anchor!.affirmationText;
                    _selectedOfferingId = state.anchor!.microOfferingId;
                    _intentionController.text = state.anchor!.intention;
                    _selectedEmotionId = state.anchor!.emotionCheckIn;
                  });
                }

                if (state is AnchorSubmissionSuccess) {
                  final authBloc = BlocProvider.of<AuthBloc>(context);
                  final offering = ZenConstants.microOfferings
                      .firstWhere((o) => o['id'] == _selectedOfferingId);
                  final int pointsEarned = offering['points'] as int;
                  authBloc.add(EmpathyPointsUpdated(pointsEarned));
                  final currentStreak = (authBloc.state is Authenticated)
                      ? (authBloc.state as Authenticated).user.streak
                      : 0;
                  authBloc.add(StreakUpdated(currentStreak + 1, _getTodayString()));
                  setState(() {
                    _currentStep = 3;
                  });
                }

                if (state is AnchorFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        backgroundColor: ZenTheme.mistRed),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AnchorLoading;

                if (isLoading && _currentStep == -1) {
                  return const Center(
                    child: CircularProgressIndicator(color: ZenTheme.sageGreen),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentStep < 3) _buildProgressIndicator(),
                      const SizedBox(height: 32),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildStepContent(textTheme, isLoading),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_currentStep < 3) _buildNavigationButtons(isLoading),
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

  // ---------------------------------------------------------------------------
  // Progress Indicator — 4 segments (Check-In, Affirmation, Offering, Intention)
  // ---------------------------------------------------------------------------
  Widget _buildProgressIndicator() {
    final activeIndex = _currentStep + 1; // -1→0, 0→1, 1→2, 2→3
    return Row(
      children: List.generate(4, (index) {
        final active = index <= activeIndex;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
            decoration: BoxDecoration(
              color: active
                  ? ZenTheme.sageGreen
                  : ZenTheme.creamWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Router các step
  // ---------------------------------------------------------------------------
  Widget _buildStepContent(TextTheme textTheme, bool isLoading) {
    switch (_currentStep) {
      case -1:
        return _buildCheckInStep(textTheme);
      case 0:
        return _buildAffirmationStep(textTheme);
      case 1:
        return _buildOfferingStep(textTheme, isLoading);
      case 2:
        return _buildIntentionStep(textTheme, isLoading);
      case 3:
      default:
        return _buildCompletedStep(textTheme);
    }
  }

  // ---------------------------------------------------------------------------
  // Step -1: Emotional Check-In
  // ---------------------------------------------------------------------------
  Widget _buildCheckInStep(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),

        // Icon tinh tế
        const Center(
          child: Icon(
            Icons.auto_awesome,
            color: ZenTheme.softGold,
            size: 20,
          ),
        ),
        const SizedBox(height: 20),

        // Heading
        Text(
          'Hôm nay, bạn đang\nmang theo cảm xúc nào?',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge!.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.normal,
            fontSize: 22,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        // Sub-heading
        Text(
          'Không có câu trả lời đúng hay sai.\nChỉ cần thành thật với bản thân.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium!.copyWith(
            fontStyle: FontStyle.italic,
            color: ZenTheme.softGray,
          ),
        ),
        const SizedBox(height: 40),

        // Grid cảm xúc
        _buildEmotionGrid(),
      ],
    );
  }

  Widget _buildEmotionGrid() {
    final firstFour = _emotionOptions.take(4).toList();
    final last = _emotionOptions.last;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildEmotionCard(firstFour[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildEmotionCard(firstFour[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildEmotionCard(firstFour[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildEmotionCard(firstFour[3])),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: _buildEmotionCard(last),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionCard(_EmotionOption option) {
    final isSelected = _selectedEmotionId == option.id;
    return _PebblePressCard(
      onTap: () => _onEmotionSelected(option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? option.accentColor.withOpacity(0.12)
              : ZenTheme.creamWhite.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? option.accentColor.withOpacity(0.5)
                : ZenTheme.creamWhite.withOpacity(0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontSize: isSelected ? 26 : 22),
              child: Text(option.emoji),
            ),
            const SizedBox(height: 8),
            if (isSelected) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: option.accentColor, size: 12),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      option.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: option.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ZenTheme.softGray,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 0: Affirmation (cá nhân hóa theo cảm xúc)
  // ---------------------------------------------------------------------------
  Widget _buildAffirmationStep(TextTheme textTheme) {
    final selectedEmotion = _emotionOptions
        .where((e) => e.id == _selectedEmotionId)
        .firstOrNull;

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'I. Gợi ý chiêm nghiệm',
          style: textTheme.bodyMedium!
              .copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Text(
          'Lời nguyện chánh niệm dành riêng cho bạn hôm nay',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),

        if (selectedEmotion != null) ...[
          const SizedBox(height: 10),
          Text(
            'Dựa trên cảm xúc của bạn: ${selectedEmotion.emoji} ${selectedEmotion.label}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selectedEmotion.accentColor.withOpacity(0.8),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],

        const SizedBox(height: 48),

        GlassContainer(
          opacity: 0.05,
          radius: 36,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.filter_vintage_outlined,
                  color: ZenTheme.softGold, size: 24),
              const SizedBox(height: 24),
              Text(
                _selectedAffirmation,
                textAlign: TextAlign.center,
                style: textTheme.displayLarge!.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: ZenTheme.creamWhite,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '— Anam Breath',
                style: textTheme.bodyMedium!.copyWith(
                  fontStyle: FontStyle.italic,
                  color: ZenTheme.softGray.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Micro-Offering
  // ---------------------------------------------------------------------------
  Widget _buildOfferingStep(TextTheme textTheme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'II. Hành Động Nhỏ (Micro-Offering)',
            style: textTheme.bodyMedium!
                .copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Chọn 1 hành động cực kỳ nhỏ để tìm lại động lực sống',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
          ),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ZenConstants.microOfferings.length,
          itemBuilder: (context, index) {
            final offering = ZenConstants.microOfferings[index];
            final isSelected = _selectedOfferingId == offering['id'];

            return _PebblePressCard(
              onTap: isLoading
                  ? null
                  : () => setState(() =>
                      _selectedOfferingId = offering['id'] as String),
              child: GlassContainer(
                margin: const EdgeInsets.only(bottom: 12),
                opacity: isSelected ? 0.12 : 0.05,
                border: Border.all(
                  color: isSelected
                      ? ZenTheme.sageGreen
                      : ZenTheme.creamWhite.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? ZenTheme.sageGreen.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.spa_outlined,
                        color: isSelected
                            ? ZenTheme.sageGreen
                            : ZenTheme.softGray,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering['title'] as String,
                            style:
                                textTheme.titleLarge!.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offering['description'] as String,
                            style:
                                textTheme.bodyMedium!.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${offering['points']} EP',
                          style: const TextStyle(
                              color: ZenTheme.softGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        Text(
                          offering['duration'] as String,
                          style: const TextStyle(
                              color: ZenTheme.softGray, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Intention
  // ---------------------------------------------------------------------------
  Widget _buildIntentionStep(TextTheme textTheme, bool isLoading) {
    return Column(
      children: [
        Text(
          'III. Lời Nguyện Ước (Intention)',
          style: textTheme.bodyMedium!
              .copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Text(
          'Viết một điều duy nhất bạn muốn hoàn thành hôm nay để thấy ngày trôi qua có ý nghĩa',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),
        const SizedBox(height: 40),
        GlassContainer(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.edit_note, color: ZenTheme.softGold, size: 28),
              const SizedBox(height: 16),
              TextField(
                controller: _intentionController,
                maxLines: 4,
                enabled: !isLoading,
                style: const TextStyle(color: ZenTheme.creamWhite),
                decoration: InputDecoration(
                  hintText:
                      "Ví dụ: 'Hôm nay, tôi muốn hoàn thành bài tập về nhà và mỉm cười với mọi người xung quanh.'",
                  hintStyle: TextStyle(
                      color: ZenTheme.softGray.withOpacity(0.5), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Hoàn thành
  // ---------------------------------------------------------------------------
  Widget _buildCompletedStep(TextTheme textTheme) {
    final selectedEmotion = _emotionOptions
        .where((e) => e.id == _selectedEmotionId)
        .firstOrNull;

    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ZenTheme.sageGreen.withOpacity(0.08),
            border: Border.all(color: ZenTheme.sageGreen, width: 1.5),
          ),
          child: const Icon(Icons.wb_sunny_outlined,
              color: ZenTheme.softGold, size: 40),
        ),
        const SizedBox(height: 32),
        Text(
          'Điểm Neo Đã Ghi Nhận',
          style: textTheme.displayMedium!
              .copyWith(fontSize: 22, color: ZenTheme.creamWhite),
        ),
        const SizedBox(height: 12),
        Text(
          'Cảm ơn bạn đã thực hiện điểm neo hôm nay. Tâm hồn bạn đã được tiếp thêm năng lượng tích cực.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),
        const SizedBox(height: 40),
        GlassContainer(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tóm tắt điểm neo hôm nay:',
                style: TextStyle(
                    color: ZenTheme.sageGreen, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (selectedEmotion != null) ...[
                _buildSummaryRow(
                    'Cảm xúc check-in:',
                    '${selectedEmotion.emoji} ${selectedEmotion.label}'),
                const Divider(color: Colors.white10),
              ],
              _buildSummaryRow('Gợi ý chiêm nghiệm:', _selectedAffirmation),
              const Divider(color: Colors.white10),
              _buildSummaryRow(
                'Hành động nhỏ:',
                ZenConstants.microOfferings.firstWhere(
                    (o) => o['id'] == _selectedOfferingId)['title'] as String,
              ),
              const Divider(color: Colors.white10),
              _buildSummaryRow('Nguyện ước:', _intentionController.text),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.push(
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
          child: const Text(
            "Lòng bạn đã lắng lại. Bạn có muốn dành 5 phút tự vấn?",
            style: TextStyle(
              color: ZenTheme.sageGreen,
              decoration: TextDecoration.underline,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ZenButton(
          text: 'Trở về Bếp Lửa',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(color: ZenTheme.softGold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: ZenTheme.creamWhite, fontSize: 14)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation buttons
  // ---------------------------------------------------------------------------
  Widget _buildNavigationButtons(bool isLoading) {
    final canProceed = _currentStep != -1 || _selectedEmotionId != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > -1)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ZenButton(
                text: 'Quay lại',
                isSecondary: true,
                onPressed:
                    isLoading ? null : () => setState(() => _currentStep--),
              ),
            ),
          )
        else
          const Spacer(),

        Expanded(
          child: Opacity(
            opacity: canProceed ? 1.0 : 0.4,
            child: ZenButton(
              text: _currentStep == 2 ? 'Hoàn thành' : 'Tiếp tục',
              isLoading: isLoading,
              onPressed: canProceed
                  ? () {
                      if (_currentStep == 1 && _selectedOfferingId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Hãy chọn một hành động nhỏ để tiếp tục.')),
                        );
                        return;
                      }
                      if (_currentStep == 2) {
                        _finishAnchor();
                      } else {
                        setState(() => _currentStep++);
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pebble Press Card — Micro-animation wrapper (DESIGN.md §5)
// ---------------------------------------------------------------------------
class _PebblePressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PebblePressCard({required this.child, this.onTap});

  @override
  State<_PebblePressCard> createState() => _PebblePressCardState();
}

class _PebblePressCardState extends State<_PebblePressCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
