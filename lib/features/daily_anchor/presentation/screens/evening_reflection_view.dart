import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/anchor_bloc.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../mind_garden/bloc/mind_garden_bloc.dart';
import '../../../mind_garden/presentation/screens/mind_garden_screen.dart';

// ---------------------------------------------------------------------------
// Model cảm xúc buổi tối — reflective (nhìn lại ngày đã qua)
// ---------------------------------------------------------------------------
class _EveningEmotion {
  final String id;
  final String emoji;
  final String label;
  final String subtitle; // mô tả dạng câu hỏi hướng dẫn
  final Color accentColor;

  const _EveningEmotion({
    required this.id,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.accentColor,
  });
}

const List<_EveningEmotion> _eveningEmotions = [
  _EveningEmotion(
    id: 'burnout',
    emoji: '🔥',
    label: 'Kiệt sức',
    subtitle: 'Hôm nay tiêu tốn nhiều năng lượng',
    accentColor: ZenTheme.mistRed,
  ),
  _EveningEmotion(
    id: 'overthinking',
    emoji: '🌀',
    label: 'Nhiều suy nghĩ',
    subtitle: 'Tâm trí vẫn còn đang chạy',
    accentColor: ZenTheme.inkBlue,
  ),
  _EveningEmotion(
    id: 'lonely',
    emoji: '🌑',
    label: 'Cô đơn',
    subtitle: 'Thiếu đi sự kết nối chân thành',
    accentColor: ZenTheme.softGray,
  ),
  _EveningEmotion(
    id: 'empty',
    emoji: '🫧',
    label: 'Trống rỗng',
    subtitle: 'Không có gì đặc biệt xảy ra',
    accentColor: ZenTheme.creamWhite,
  ),
  _EveningEmotion(
    id: 'peaceful',
    emoji: '☀️',
    label: 'Bình yên',
    subtitle: 'Ngày hôm nay đi qua nhẹ nhàng',
    accentColor: ZenTheme.sageGreen,
  ),
  _EveningEmotion(
    id: 'grateful',
    emoji: '🌸',
    label: 'Biết ơn',
    subtitle: 'Có điều gì đó đáng trân trọng',
    accentColor: ZenTheme.softGold,
  ),
];

// ---------------------------------------------------------------------------
// Evening Reflection View
// ---------------------------------------------------------------------------
class EveningReflectionView extends StatefulWidget {
  const EveningReflectionView({super.key});

  @override
  State<EveningReflectionView> createState() => _EveningReflectionViewState();
}

class _EveningReflectionViewState extends State<EveningReflectionView>
    with TickerProviderStateMixin {
  // step 0: Emotion Check-In ("Ngày hôm nay mang đến cho bạn cảm xúc gì?")
  // step 1: Nhìn lại Ý định sáng nay (intentionReview)
  // step 2: Ghi chú nhanh (1 điều học/cảm nhận được)
  // step 3: Khép lại ngày hôm nay
  int _currentStep = 0;

  String? _selectedEmotionId;
  bool? _intentionAchieved;
  final _noteController = TextEditingController();

  // Morning anchor (loaded to show intention for review)
  String? _morningIntention;
  bool _morningAnchorLoaded = false;

  // Celebration pulse animation
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTodayAnchor());
  }

  void _loadTodayAnchor() {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final anchorBloc = BlocProvider.of<AnchorBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';
    if (uid.isNotEmpty) {
      anchorBloc.add(CheckTodayAnchorRequested(uid, _getTodayString()));
    }
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _setEmotion(String id) {
    setState(() => _selectedEmotionId = id);
    // Cross-feature emotional loop: evening emotion → personalizes Gương tự vấn
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context);
    if (id == 'burnout')
      dbRepo.currentMindState = 'burnout_state';
    else if (id == 'overthinking')
      dbRepo.currentMindState = 'overthinking_state';
    else if (id == 'lonely')
      dbRepo.currentMindState = 'lonely_state';
    else if (id == 'empty')
      dbRepo.currentMindState = 'lonely_state';
    else if (id == 'peaceful')
      dbRepo.currentMindState = 'peaceful_state';
    else if (id == 'grateful')
      dbRepo.currentMindState = 'peaceful_state';
    else
      dbRepo.currentMindState = null;
  }

  void _submitEvening() {
    if (_selectedEmotionId == null) return;

    HapticFeedback.mediumImpact();

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final anchorBloc = BlocProvider.of<AnchorBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';

    anchorBloc.add(
      CompleteEveningReflectionRequested(
        uid: uid,
        date: _getTodayString(),
        emotion: _selectedEmotionId!,
        note: _noteController.text.trim(),
        intentionAchieved: _intentionAchieved ?? false,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: ZenTheme.creamWhite,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nhìn Lại Cuối Ngày',
          style: textTheme.titleLarge!.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
          SafeArea(
            child: BlocConsumer<AnchorBloc, AnchorState>(
              listener: (context, state) {
                // Load morning anchor để lấy intention
                if (state is AnchorLoadSuccess && !_morningAnchorLoaded) {
                  setState(() {
                    _morningAnchorLoaded = true;
                    _morningIntention = state.anchor?.intention;
                    // Nếu evening đã hoàn thành → nhảy thẳng đến step 3
                    if (state.anchor != null &&
                        state.anchor!.eveningCompleted) {
                      _currentStep = 3;
                      _selectedEmotionId = state.anchor!.eveningEmotion;
                    }
                  });
                }
                if (state is EveningReflectionSuccess) {
                  setState(() => _currentStep = 3);
                }
                if (state is AnchorFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: ZenTheme.mistRed,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AnchorLoading;
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_currentStep < 3) ...[
                        _buildProgressIndicator(),
                        const SizedBox(height: 28),
                      ],
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildStepContent(textTheme, isLoading),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_currentStep < 3)
                        _buildNavigationButtons(isLoading)
                      else
                        ZenButton(
                          text: 'Trở về Bếp Lửa',
                          onPressed: () => Navigator.pop(context),
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

  // ---------------------------------------------------------------------------
  // Progress bar — 3 bước tối
  // ---------------------------------------------------------------------------
  Widget _buildProgressIndicator() {
    final labels = ['Cảm xúc', 'Ý định ngày mới', 'Ghi chú'];
    return Column(
      children: [
        Row(
          children: List.generate(3, (i) {
            final active = i <= _currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
                decoration: BoxDecoration(
                  color: active
                      ? ZenTheme.inkBlue
                      : ZenTheme.creamWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(3, (i) {
            final active = i <= _currentStep;
            return Expanded(
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 0.4,
                  color: active
                      ? ZenTheme.inkBlue.withOpacity(0.9)
                      : ZenTheme.softGray.withOpacity(0.35),
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepContent(TextTheme textTheme, bool isLoading) {
    switch (_currentStep) {
      case 0:
        return _buildEmotionStep(textTheme);
      case 1:
        return _buildIntentionReviewStep(textTheme);
      case 2:
        return _buildNoteStep(textTheme, isLoading);
      case 3:
      default:
        return _buildCompletedStep(textTheme);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 0: Emotion Check-In — Reflective (nhìn lại ngày đã qua)
  // ---------------------------------------------------------------------------
  Widget _buildEmotionStep(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: ZenTheme.creamWhite.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ZenTheme.creamWhite.withOpacity(0.08)),
            ),
            child: Text(
              '🌙  Nhìn lại cuối ngày  ·  ~3 phút',
              style: textTheme.bodyMedium!.copyWith(
                color: ZenTheme.softGray.withOpacity(0.7),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Icon(
            Icons.nightlight_outlined,
            color: ZenTheme.inkBlue,
            size: 22,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ngày hôm nay đã mang đến\ncho bạn cảm xúc gì?',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge!.copyWith(
            fontFamily: 'Lora',
            fontWeight: FontWeight.normal,
            fontSize: 22,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Không cần phân tích — chỉ cần nhận ra và đặt tên cho cảm xúc đó.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium!.copyWith(
            fontStyle: FontStyle.italic,
            color: ZenTheme.softGray,
          ),
        ),
        const SizedBox(height: 32),

        // Emotion grid 3×2
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildEmotionCard(_eveningEmotions[0])),
                const SizedBox(width: 12),
                Expanded(child: _buildEmotionCard(_eveningEmotions[1])),
                const SizedBox(width: 12),
                Expanded(child: _buildEmotionCard(_eveningEmotions[2])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildEmotionCard(_eveningEmotions[3])),
                const SizedBox(width: 12),
                Expanded(child: _buildEmotionCard(_eveningEmotions[4])),
                const SizedBox(width: 12),
                Expanded(child: _buildEmotionCard(_eveningEmotions[5])),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),
        // Gợi ý affirmation phù hợp với cảm xúc đã chọn
        if (_selectedEmotionId != null) ...[
          const SizedBox(height: 16),
          _buildEmotionAffirmation(textTheme),
          _buildEmotionGardenHint(_selectedEmotionId!),
        ],
      ],
    );
  }

  Widget _buildEmotionCard(_EveningEmotion em) {
    final isSelected = _selectedEmotionId == em.id;
    return GestureDetector(
      onTap: () => _setEmotion(em.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? em.accentColor.withOpacity(0.12)
              : ZenTheme.creamWhite.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? em.accentColor.withOpacity(0.5)
                : ZenTheme.creamWhite.withOpacity(0.08),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontSize: isSelected ? 24 : 20),
              child: Text(em.emoji),
            ),
            const SizedBox(height: 5),
            Text(
              em.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? em.accentColor : ZenTheme.softGray,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionAffirmation(TextTheme textTheme) {
    // Lấy affirmation phù hợp với cảm xúc để làm "gương chiếu"
    final emotionKey = _selectedEmotionId == 'grateful'
        ? 'peaceful'
        : (_selectedEmotionId ?? 'peaceful');
    final affirmations = ZenConstants.emotionalAffirmations[emotionKey];
    if (affirmations == null || affirmations.isEmpty)
      return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZenTheme.creamWhite.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZenTheme.creamWhite.withOpacity(0.07)),
      ),
      child: Text(
        '"${affirmations[DateTime.now().hour % affirmations.length]}"',
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium!.copyWith(
          color: ZenTheme.softGray.withOpacity(0.8),
          fontStyle: FontStyle.italic,
          height: 1.5,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildEmotionGardenHint(String emotionId) {
    String hint = "";
    switch (emotionId) {
      case 'peaceful':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng ☀️ trong Vườn Tâm Trí.";
        break;
      case 'grateful':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng 🌸 trong Vườn Tâm Trí.";
        break;
      case 'burnout':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng 🔥 trong Vườn Tâm Trí.";
        break;
      case 'overthinking':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng 🌀 trong Vườn Tâm Trí.";
        break;
      case 'lonely':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng 🌑 trong Vườn Tâm Trí.";
        break;
      case 'empty':
        hint =
            "Cảm xúc này sẽ hiển thị dưới dạng biểu tượng 🫧 trong Vườn Tâm Trí.";
        break;
    }
    if (hint.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.filter_vintage_outlined,
            color: ZenTheme.sageGreen,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: ZenTheme.sageGreen,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1: Nhìn lại Ý định sáng nay
  // ---------------------------------------------------------------------------
  Widget _buildIntentionReviewStep(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'II. Nhìn Lại Ý Định',
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.inkBlue,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Sáng nay ý định của bạn là gì?',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
          ),
        ),
        const SizedBox(height: 32),

        if (_morningIntention != null && _morningIntention!.isNotEmpty) ...[
          GlassContainer(
            opacity: 0.05,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.brightness_6_outlined,
                      color: ZenTheme.sageGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ý định buổi sáng của bạn:',
                      style: TextStyle(
                        color: ZenTheme.sageGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"$_morningIntention"',
                  style: textTheme.bodyLarge!.copyWith(
                    color: ZenTheme.creamWhite,
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Bạn đã thực hiện điều này chưa?',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge!.copyWith(
              fontSize: 17,
              color: ZenTheme.creamWhite,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReviewChoice(
                  emoji: '✅',
                  label: 'Đã làm được!',
                  sublabel: 'Tốt lắm, bạn đã giữ lời với bản thân',
                  color: ZenTheme.sageGreen,
                  selected: _intentionAchieved == true,
                  onTap: () => setState(() => _intentionAchieved = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReviewChoice(
                  emoji: '🔄',
                  label: 'Chưa hoàn thành',
                  sublabel: 'Không sao — ngày mai là cơ hội mới',
                  color: ZenTheme.inkBlue,
                  selected: _intentionAchieved == false,
                  onTap: () => setState(() => _intentionAchieved = false),
                ),
              ),
            ],
          ),
        ] else ...[
          // Không có morning anchor → skip review, cho phép continue
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ZenTheme.creamWhite.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ZenTheme.creamWhite.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.wb_twilight,
                  color: ZenTheme.softGold,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  'Bạn chưa đặt ý định sáng nay.\nHôm nay chỉ cần nhìn lại cảm xúc đã là đủ.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge!.copyWith(
                    color: ZenTheme.softGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewChoice({
    required String emoji,
    required String label,
    required String sublabel,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.12)
              : ZenTheme.creamWhite.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.4)
                : ZenTheme.creamWhite.withOpacity(0.08),
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: selected ? 28 : 24)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? color : ZenTheme.softGray,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ZenTheme.softGray.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2: Ghi Chú Nhanh
  // ---------------------------------------------------------------------------
  Widget _buildNoteStep(TextTheme textTheme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'III. Ghi chú nhanh',
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.inkBlue,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Một điều bạn học hoặc cảm nhận được hôm nay',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '(Không cần hoàn hảo — một từ, một câu đều được)',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
              color: ZenTheme.softGray.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 28),
        GlassContainer(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.nights_stay_outlined,
                color: ZenTheme.inkBlue,
                size: 26,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 5,
                enabled: !isLoading,
                style: const TextStyle(
                  color: ZenTheme.creamWhite,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText:
                      "Ví dụ: \"Hôm nay tôi học được rằng...\" hoặc chỉ \"Cần nghỉ ngơi nhiều hơn\"",
                  hintStyle: TextStyle(
                    color: ZenTheme.softGray.withOpacity(0.4),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Gợi ý nhanh
        const Text(
          'Gợi ý:',
          style: TextStyle(color: ZenTheme.softGold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'Cần lắng nghe bản thân hơn',
                    'Biết ơn vì...',
                    'Muốn thử lại...',
                    'Hôm nay thách thức nhất là...',
                  ]
                  .map(
                    (hint) => GestureDetector(
                      onTap: () {
                        _noteController.text = hint;
                        _noteController.selection = TextSelection.fromPosition(
                          TextPosition(offset: hint.length),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ZenTheme.creamWhite.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ZenTheme.creamWhite.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          hint,
                          style: TextStyle(
                            color: ZenTheme.softGray.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Khép lại ngày hôm nay
  // ---------------------------------------------------------------------------
  Widget _buildCompletedStep(TextTheme textTheme) {
    final selectedEmotion = _eveningEmotions
        .where((e) => e.id == _selectedEmotionId)
        .firstOrNull;

    return Column(
      children: [
        const SizedBox(height: 40),
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) => Transform.scale(
            scale: _pulseAnim.value,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZenTheme.inkBlue.withOpacity(0.1),
                border: Border.all(color: ZenTheme.inkBlue, width: 1.5),
              ),
              child: const Icon(
                Icons.nightlight_rounded,
                color: ZenTheme.inkBlue,
                size: 40,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        Text(
          'Tâm trí bạn giờ đây đã sẵn sàng nghỉ ngơi.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(
            color: ZenTheme.softGray,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        if (selectedEmotion != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedEmotion.accentColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedEmotion.accentColor.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Text(
                  selectedEmotion.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cảm xúc hôm nay: ${selectedEmotion.label}',
                        style: TextStyle(
                          color: selectedEmotion.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedEmotion.subtitle,
                        style: TextStyle(
                          color: ZenTheme.softGray.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),
        // CTA: Vườn Tâm Trí
        GlassContainer(
          opacity: 0.04,
          child: Column(
            children: [
              const Icon(
                Icons.filter_vintage_outlined,
                color: ZenTheme.sageGreen,
                size: 24,
              ),
              const SizedBox(height: 10),
              Text(
                'Lòng bạn đã lắng lại. Hãy ghé thăm Vườn Tâm Trí để nhìn lại hành trình cảm xúc.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<MindGardenBloc>(
                      create: (ctx) => MindGardenBloc(
                        databaseRepository:
                            RepositoryProvider.of<BaseDatabaseRepository>(ctx),
                      ),
                      child: const MindGardenScreen(),
                    ),
                  ),
                ),
                child: const Text(
                  'Vào Vườn Tâm Trí →',
                  style: TextStyle(
                    color: ZenTheme.sageGreen,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation buttons
  // ---------------------------------------------------------------------------
  Widget _buildNavigationButtons(bool isLoading) {
    bool canProceed;
    switch (_currentStep) {
      case 0:
        canProceed = _selectedEmotionId != null;
        break;
      case 1:
        canProceed =
            _intentionAchieved != null ||
            _morningIntention == null ||
            _morningIntention!.isEmpty;
        break;
      case 2:
        canProceed = true; // Note là optional
      default:
        canProceed = true;
    }

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ZenButton(
                text: 'Quay lại',
                isSecondary: true,
                onPressed: isLoading
                    ? null
                    : () => setState(() => _currentStep--),
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
                      if (_currentStep == 2) {
                        _submitEvening();
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
