import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/anchor_bloc.dart';

/// Morning Anchor Ritual — Nghi thức buổi sáng
/// Flow: Nguyện ước → Hành động nhỏ → Gợi ý chiêm nghiệm → Hoàn thành
/// Không có Emotion Check-In (dành cho buổi tối)
class AnchorView extends StatefulWidget {
  const AnchorView({super.key});

  @override
  State<AnchorView> createState() => _AnchorViewState();
}

class _AnchorViewState extends State<AnchorView> with TickerProviderStateMixin {
  // step 0: Lời Nguyện Ước (Intention) ← đặt ý định trước
  // step 1: Hành Động Nhỏ (Micro-Offering)
  // step 2: Gợi Ý Chiêm Nghiệm (Affirmation)
  // step 3: Hoàn thành buổi sáng
  int _currentStep = 0;

  late String _selectedAffirmation;
  late Map<String, dynamic> _selectedFlashcard;
  String? _selectedOfferingId;
  final _intentionController = TextEditingController();

  // Closing ritual animation
  late final AnimationController _rippleController;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;
  bool _showRipple = false;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rippleScale = Tween<double>(begin: 0.0, end: 2.5).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    // Affirmation buổi sáng — dùng pool chung (không cần emotion)
    _selectedAffirmation = _pickRandomAffirmation();
    _selectedFlashcard = _pickFlashcard();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayAnchor();
    });
  }

  String _pickRandomAffirmation() {
    return ZenConstants.dailyAffirmations[Random().nextInt(
      ZenConstants.dailyAffirmations.length,
    )];
  }

  Map<String, dynamic> _pickFlashcard() {
    final cards = ZenConstants.wisdomFlashcards;
    return cards[Random().nextInt(cards.length)];
  }

  void _refreshAffirmation() {
    setState(() {
      _selectedAffirmation = _pickRandomAffirmation();
      _selectedFlashcard = _pickFlashcard();
    });
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

  void _finishMorningAnchor() {
    if (_intentionController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _showRipple = true);
    _rippleController.forward().then((_) {
      if (mounted) {
        setState(() => _showRipple = false);
        _rippleController.reset();
      }
    });

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final anchorBloc = BlocProvider.of<AnchorBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';

    anchorBloc.add(
      CompleteTodayAnchorRequested(
        uid: uid,
        date: _getTodayString(),
        affirmation: _selectedAffirmation,
        microOfferingId: _selectedOfferingId ?? 'breathe',
        intention: _intentionController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _intentionController.dispose();
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
          'Ý niệm ngày mới',
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
                // Hôm nay đã hoàn thành morning anchor
                if (state is AnchorLoadSuccess &&
                    state.anchor != null &&
                    state.anchor!.morningCompleted) {
                  setState(() {
                    _currentStep = 3;
                    _selectedAffirmation = state.anchor!.affirmationText;
                    _selectedOfferingId = state.anchor!.microOfferingId;
                    _intentionController.text = state.anchor!.intention;
                  });
                }
                if (state is AnchorSubmissionSuccess) {
                  final authBloc = BlocProvider.of<AuthBloc>(context);
                  final offering = ZenConstants.microOfferings.firstWhere(
                    (o) => o['id'] == _selectedOfferingId,
                  );
                  authBloc.add(EmpathyPointsUpdated(offering['points'] as int));
                  final currentStreak = (authBloc.state is Authenticated)
                      ? (authBloc.state as Authenticated).user.streak
                      : 0;
                  authBloc.add(
                    StreakUpdated(currentStreak + 1, _getTodayString()),
                  );
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
                if (isLoading && _currentStep == 0) {
                  return const Center(
                    child: CircularProgressIndicator(color: ZenTheme.sageGreen),
                  );
                }
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
                          text: 'Bắt đầu ngày mới',
                          onPressed: () => Navigator.pop(context),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Closing ritual ripple
          if (_showRipple)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _rippleController,
                  builder: (context, _) => Center(
                    child: Transform.scale(
                      scale: _rippleScale.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ZenTheme.sageGreen.withOpacity(
                            _rippleOpacity.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Progress bar — 3 bước sáng
  // ---------------------------------------------------------------------------
  Widget _buildProgressIndicator() {
    final labels = ['Ý định ngày mới', 'Hành động', 'Chiêm nghiệm'];
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
                      ? ZenTheme.sageGreen
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
                      ? ZenTheme.sageGreen.withOpacity(0.9)
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
        return _buildIntentionStep(textTheme, isLoading);
      case 1:
        return _buildOfferingStep(textTheme, isLoading);
      case 2:
        return _buildAffirmationStep(textTheme);
      case 3:
      default:
        return _buildCompletedStep(textTheme);
    }
  }

  // ---------------------------------------------------------------------------
  // Step 0: Ý định ngày mới — Đặt định hướng cho ngày
  // ---------------------------------------------------------------------------
  Widget _buildIntentionStep(TextTheme textTheme, bool isLoading) {
    final templates = ZenConstants.intentionTemplates['neutral']!;

    // Triday Question — chọn theo giờ trong ngày
    final hour = DateTime.now().hour;
    final String tridayKey = hour >= 5 && hour < 12
        ? 'morning'
        : hour >= 12 && hour < 17
            ? 'afternoon'
            : 'evening';
    final tridayQuestion = ZenConstants.tridayQuestions[tridayKey]!;

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
              '☀️  Định hướng ngày mới  ·  ~3 phút',
              style: textTheme.bodyMedium!.copyWith(
                color: ZenTheme.softGray.withOpacity(0.7),
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Triday Question Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                ZenTheme.sageGreen.withOpacity(0.08),
                ZenTheme.inkBlue.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: ZenTheme.sageGreen.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧭',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'La bàn nội sinh',
                      style: textTheme.bodyMedium!.copyWith(
                        color: ZenTheme.sageGreen,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tridayQuestion,
                      style: textTheme.bodyLarge!.copyWith(
                        color: ZenTheme.creamWhite.withOpacity(0.88),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Center(
          child: Icon(
            Icons.brightness_6_outlined,
            color: ZenTheme.sageGreen,
            size: 22,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'I. Ý định ngày mới',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium!.copyWith(
            color: ZenTheme.sageGreen,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Một điều duy nhất bạn muốn thực hiện hôm nay',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),
        const SizedBox(height: 20),

        // Intention Templates
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: templates.map((t) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _intentionController.text = t;
                  _intentionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: t.length),
                  );
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: ZenTheme.softGold.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ZenTheme.softGold.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: ZenTheme.softGold,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        t,
                        style: TextStyle(
                          color: ZenTheme.softGold.withOpacity(0.9),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        GlassContainer(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.edit_note, color: ZenTheme.softGold, size: 26),
              const SizedBox(height: 12),
              TextField(
                controller: _intentionController,
                maxLines: 4,
                enabled: !isLoading,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  color: ZenTheme.creamWhite,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: "Tiếp tục câu trên hoặc viết điều của riêng bạn...",
                  hintStyle: TextStyle(
                    color: ZenTheme.softGray.withOpacity(0.45),
                    fontSize: 13,
                  ),
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
  // Step 1: Hành Động Nhỏ (Micro-Offering)
  // ---------------------------------------------------------------------------
  Widget _buildOfferingStep(TextTheme textTheme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'II. Hành động nhỏ',
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.sageGreen,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Chọn 1 hành động nhỏ để khởi đầu ngày',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
          ),
        ),
        const SizedBox(height: 20),
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
                  : () => setState(
                      () => _selectedOfferingId = offering['id'] as String,
                    ),
              child: GlassContainer(
                margin: const EdgeInsets.only(bottom: 10),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering['title'] as String,
                            style: textTheme.titleLarge!.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            offering['description'] as String,
                            style: textTheme.bodyMedium!.copyWith(fontSize: 11),
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
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          offering['duration'] as String,
                          style: const TextStyle(
                            color: ZenTheme.softGray,
                            fontSize: 10,
                          ),
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
  // Step 2: Flashcard Tri Thức Nội Sinh + Gợi Ý Chiêm Nghiệm
  // ---------------------------------------------------------------------------
  Widget _buildAffirmationStep(TextTheme textTheme) {
    final circuit = ZenConstants.endogenCircuits
        .firstWhere((c) => c['id'] == _selectedFlashcard['circuit']);
    final circuitColor = Color(circuit['color'] as int);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'III. Thẻ tri thức nội sinh',
          style: textTheme.bodyMedium!.copyWith(
            color: ZenTheme.sageGreen,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Mang theo câu hỏi này trong suốt ngày hôm nay',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),
        const SizedBox(height: 24),

        // Wisdom Flashcard
        Stack(
          children: [
            GlassContainer(
              opacity: 0.06,
              radius: 28,
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
              border: Border.all(
                color: circuitColor.withOpacity(0.25),
                width: 1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circuit badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: circuitColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: circuitColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${circuit['icon']}  Mạch ${circuit['id']} — ${circuit['name']}',
                      style: textTheme.bodyMedium!.copyWith(
                        color: circuitColor,
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Quote
                  Text(
                    '"${_selectedFlashcard['quote']}"',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: ZenTheme.creamWhite,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: circuitColor.withOpacity(0.15), height: 1),
                  const SizedBox(height: 20),

                  // Question
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.help_outline_rounded, color: ZenTheme.softGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFlashcard['question'] as String,
                          style: textTheme.bodyLarge!.copyWith(
                            color: ZenTheme.creamWhite.withOpacity(0.82),
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Source
                  Text(
                    '— ${_selectedFlashcard['source']}',
                    style: textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                      color: ZenTheme.softGray.withOpacity(0.55),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Tooltip(
                message: 'Thẻ khác',
                child: GestureDetector(
                  onTap: _refreshAffirmation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ZenTheme.creamWhite.withOpacity(0.06),
                      shape: BoxShape.circle,
                      border: Border.all(color: ZenTheme.creamWhite.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: ZenTheme.softGray, size: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3: Hoàn thành buổi sáng
  // ---------------------------------------------------------------------------
  Widget _buildCompletedStep(TextTheme textTheme) {
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
          child: const Icon(
            Icons.brightness_6_outlined,
            color: ZenTheme.sageGreen,
            size: 40,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Định hướng ngày mới hoàn tất',
          textAlign: TextAlign.center,
          style: textTheme.displayMedium!.copyWith(
            fontSize: 22,
            color: ZenTheme.creamWhite,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bạn đã đặt ý định cho ngày hôm nay. Hãy mang theo ý định này và quay lại vào buổi tối để nhìn lại.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(
            color: ZenTheme.softGray,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        GlassContainer(
          opacity: 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ý định của bạn hôm nay:',
                style: TextStyle(
                  color: ZenTheme.sageGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${_intentionController.text}"',
                style: const TextStyle(
                  color: ZenTheme.creamWhite,
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                ),
              ),
              const Divider(color: Colors.white10, height: 24),
              const Text(
                'Hành động nhỏ đã chọn:',
                style: TextStyle(color: ZenTheme.softGold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedOfferingId != null
                    ? ZenConstants.microOfferings.firstWhere(
                            (o) => o['id'] == _selectedOfferingId,
                          )['title']
                          as String
                    : '',
                style: const TextStyle(
                  color: ZenTheme.creamWhite,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gợi ý Micro-Ritual từ Mạch 3
        _buildMicroRitualSuggestion(textTheme),
      ],
    );
  }

  Widget _buildMicroRitualSuggestion(TextTheme textTheme) {
    if (ZenConstants.endogenMicroRituals.isEmpty) return const SizedBox();
    final ritual = ZenConstants.endogenMicroRituals[
        Random().nextInt(ZenConstants.endogenMicroRituals.length)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ZenTheme.softGold.withOpacity(0.06),
        border: Border.all(color: ZenTheme.softGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Nghi lễ nhỏ gợi ý hôm nay',
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGold,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                ritual['duration'] as String,
                style: textTheme.bodyMedium!.copyWith(
                  color: ZenTheme.softGray,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ritual['title'] as String,
            style: textTheme.titleLarge!.copyWith(
              fontSize: 14,
              color: ZenTheme.creamWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ritual['instruction'] as String,
            style: textTheme.bodyMedium!.copyWith(
              fontSize: 12,
              color: ZenTheme.softGray,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation buttons
  // ---------------------------------------------------------------------------
  Widget _buildNavigationButtons(bool isLoading) {
    final canProceed =
        _currentStep != 0 || _intentionController.text.trim().isNotEmpty;

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
              text: _currentStep == 2 ? 'Hoàn thành ý niệm' : 'Tiếp tục',
              isLoading: isLoading,
              onPressed: canProceed
                  ? () {
                      if (_currentStep == 1 && _selectedOfferingId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hãy chọn một hành động nhỏ để tiếp tục.',
                            ),
                          ),
                        );
                        return;
                      }
                      if (_currentStep == 2) {
                        _finishMorningAnchor();
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
// Pebble Press Card
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
