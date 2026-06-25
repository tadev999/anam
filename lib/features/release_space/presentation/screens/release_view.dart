import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../bloc/release_bloc.dart';
import '../widgets/release_particle_effect.dart';
import '../../../../features/hearth/presentation/screens/hearth_view.dart';
import '../../../../features/silence/presentation/screens/silence_view.dart';
import '../../../../features/daily_anchor/presentation/screens/anchor_view.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../reflection/bloc/reflection_bloc.dart';
import '../../../reflection/presentation/screens/reflection_view.dart';

enum ReleaseStep { write, transition, theReturn }

enum ReflectionChip {
  langeNghe("Cần được lắng nghe", ZenTheme.sageGreen),
  nghiNgoi("Cần được nghỉ ngơi", ZenTheme.inkBlue),
  thaThu("Cần được tha thứ", ZenTheme.softGold);

  final String label;
  final Color accentColor;
  const ReflectionChip(this.label, this.accentColor);
}

class ReleaseView extends StatefulWidget {
  const ReleaseView({super.key});

  @override
  State<ReleaseView> createState() => _ReleaseViewState();
}

class _ReleaseViewState extends State<ReleaseView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isBurning = false;
  ReleaseStep _currentStep = ReleaseStep.write;
  ReflectionChip? _selectedChip;
  bool _isFocusMode = false;

  void _burnRelease() {
    if (_controller.text.trim().isEmpty) return;

    // Kích hoạt hiệu ứng hạt bay trước
    setState(() {
      _isBurning = true;
    });
  }

  void _onBurnComplete() {
    final confBloc = BlocProvider.of<ReleaseBloc>(context);

    // Đốt xong thì dispatch Event lưu lên Firestore/Mock
    confBloc.add(SubmitReleaseRequested(_controller.text.trim()));
  }

  void _resetFlow() {
    setState(() {
      _controller.clear();
      _isBurning = false;
      _currentStep = ReleaseStep.write;
      _selectedChip = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocusMode = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: _currentStep == ReleaseStep.write,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // canPop is false if _currentStep is transition or theReturn, so close the page and go back to Home
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: ZenTheme.creamWhite,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            "Khoảng buông",
            style: textTheme.titleLarge!.copyWith(
              fontFamily: 'Lora',
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // Nền Gradient sâu lôi cuốn
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ZenTheme.slateDark, Color(0xff141014)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: GestureDetector(
                onTap: () {
                  _focusNode.unfocus();
                },
                behavior: HitTestBehavior.opaque,
                child: BlocConsumer<ReleaseBloc, ReleaseState>(
                  listener: (context, state) {
                    if (state is ReleaseSuccess) {
                      setState(() {
                        _isBurning = false;
                        _currentStep = ReleaseStep.transition;
                        _controller.clear();
                      });
                    }

                    if (state is ReleaseFailure) {
                      setState(() {
                        _isBurning = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: ZenTheme.mistRed,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is ReleaseLoading;

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildBody(textTheme, isLoading || _isBurning),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TextTheme textTheme, bool isLocked) {
    switch (_currentStep) {
      case ReleaseStep.write:
        return _buildWriteView(textTheme, isLocked);
      case ReleaseStep.transition:
        return _buildTransitionView(textTheme);
      case ReleaseStep.theReturn:
        return _buildReturnView(textTheme);
    }
  }

  Widget _buildWriteView(TextTheme textTheme, bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isFocusMode) ...[
          Text(
            "Hãy trút bỏ gánh nặng tiêu cực",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge!.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Viết ra tổn thương, lo âu hay lỗi lầm của bạn hoàn toàn ẩn danh. Sau đó, hãy gửi chúng vào hư vô.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
        ] else ...[
          const SizedBox(height: 12),
        ],

        Expanded(
          child: ReleaseParticleEffect(
            isBurning: _isBurning,
            onComplete: _onBurnComplete,
            child: GlassContainer(
              opacity: 0.05,
              radius: 28,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.nights_stay_outlined,
                    color: ZenTheme.mistRed,
                    size: 24,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: null,
                      enabled: !isLocked,
                      style: GoogleFonts.nunito(
                        color: ZenTheme.creamWhite,
                        height: 1.6,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "Thành thật với chính mình. Không ai phán xét bạn ở đây...",
                        hintStyle: GoogleFonts.nunito(
                          color: ZenTheme.softGray.withValues(alpha: 0.4),
                          height: 1.6,
                          fontSize: 17,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1.0,
                child: child,
              ),
            );
          },
          child: _isFocusMode
              ? const SizedBox.shrink()
              : Column(
                  key: const ValueKey('bottom_action'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    if (!isLocked)
                      ZenButton(
                        text: "Gửi vào hư vô",
                        icon: Icons.cloud_queue,
                        onPressed: () {
                          if (_controller.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Nhập chia sẻ trước khi gửi vào hư vô."),
                              ),
                            );
                            return;
                          }
                          _burnRelease();
                        },
                      )
                    else if (_isBurning)
                      const Center(
                        child: CircularProgressIndicator(color: ZenTheme.mistRed),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTransitionView(TextTheme textTheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Center(child: _AshDissolveAnimation()),
                  const SizedBox(height: 16),
                  Text(
                    "Nỗi lòng đã trôi vào hư vô.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 20,
                      color: ZenTheme.creamWhite,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Trước khi bước tiếp — hãy dừng lại một giây.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: ZenTheme.softGray,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  GlassContainer(
                    opacity: 0.05,
                    radius: 28,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Điều bạn vừa viết ra nói lên nhu cầu nào của bạn hôm nay?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 17,
                            color: ZenTheme.creamWhite,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: ReflectionChip.values.map((chip) {
                            return _ReflectionChipWidget(
                              chip: chip,
                              isSelected: _selectedChip == chip,
                              onTap: () {
                                setState(() {
                                  _selectedChip = chip;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Spacer(),
                  Opacity(
                    opacity: _selectedChip != null ? 1.0 : 0.4,
                    child: IgnorePointer(
                      ignoring: _selectedChip == null,
                      child: ZenButton(
                        text: "Tiếp tục",
                        onPressed: () {
                          if (_selectedChip != null) {
                            final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(
                              context,
                            );
                            if (_selectedChip == ReflectionChip.langeNghe) {
                              dbRepo.currentMindState = 'lonely_state';
                            } else if (_selectedChip == ReflectionChip.nghiNgoi) {
                              dbRepo.currentMindState = 'burnout_state';
                            } else if (_selectedChip == ReflectionChip.thaThu) {
                              dbRepo.currentMindState = 'overthinking_state';
                            }
                          }
                          setState(() {
                            _currentStep = ReleaseStep.theReturn;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReturnView(TextTheme textTheme) {
    if (_selectedChip == null) return const SizedBox.shrink();

    String headingText = "";
    String subText = "";

    switch (_selectedChip!) {
      case ReflectionChip.langeNghe:
        headingText = "Bạn đã lắng nghe chính mình.";
        subText =
            "Đó là một hành động dũng cảm. Bếp Lửa Chung luôn ở đây nếu bạn muốn biết rằng có người đang cùng cảm giác với bạn.";
        break;
      case ReflectionChip.nghiNgoi:
        headingText = "Bạn được phép nghỉ ngơi.";
        subText =
            "Không cần làm gì thêm hôm nay. Khoảng Lặng là nơi bạn có thể ở lại trong yên lặng một lúc.";
        break;
      case ReflectionChip.thaThu:
        headingText = "Bạn đã tha thứ cho chính mình.";
        subText =
            "Gửi đi nghĩa là buông. Ý niệm ngày mới hôm nay có thể là bước tiếp theo — một hành động nhỏ từ vị trí đứng mới này.";
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Center(child: _PulseCheckIcon()),
                  const SizedBox(height: 28),
                  Text(
                    headingText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 20,
                      color: ZenTheme.creamWhite,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      subText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: ZenTheme.softGray,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  _buildMicroActionCard(_selectedChip!),

                  const SizedBox(height: 20),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<ReflectionBloc>(
                          create: (context) => ReflectionBloc(
                            databaseRepository:
                                RepositoryProvider.of<BaseDatabaseRepository>(context),
                          ),
                          child: const ReflectionView(),
                        ),
                      ),
                    ),
                    child: Text(
                      "Lòng bạn đã buông bỏ. Bạn có muốn dành 5 phút tự thấu hiểu cùng Gương tự vấn?",
                      style: GoogleFonts.nunito(
                        color: ZenTheme.sageGreen,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ZenButton(
                    text: "Về Bếp Lửa chính",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _resetFlow,
                      child: Text(
                        "Viết thêm một điều khác",
                        style: GoogleFonts.nunito(
                          color: ZenTheme.sageGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicroActionCard(ReflectionChip chip) {
    IconData icon;
    String actionText;
    Widget destination;

    switch (chip) {
      case ReflectionChip.langeNghe:
        icon = Icons.people_outline_outlined;
        actionText = "Đọc chia sẻ của người đang ngồi quanh Bếp Lửa";
        destination = const HearthView();
        break;
      case ReflectionChip.nghiNgoi:
        icon = Icons.spa_outlined;
        actionText = "Ngồi yên một lúc trong Khoảng Lặng";
        destination = const SilenceView();
        break;
      case ReflectionChip.thaThu:
        icon = Icons.brightness_6_outlined;
        actionText = "Làm một hành động nhỏ trong Ý niệm ngày mới hôm nay";
        destination = const AnchorView();
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: GlassContainer(
        opacity: 0.06,
        radius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: ZenTheme.softGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Bạn muốn thử...",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: ZenTheme.softGray,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              actionText,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: ZenTheme.creamWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "→ Đến đây",
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: ZenTheme.sageGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AshDissolveAnimation extends StatefulWidget {
  const _AshDissolveAnimation();

  @override
  State<_AshDissolveAnimation> createState() => _AshDissolveAnimationState();
}

class _AshDissolveAnimationState extends State<_AshDissolveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.8,
        end: 0.1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 0.85,
        ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: const Icon(
          Icons.blur_on_outlined,
          size: 40,
          color: ZenTheme.mistRed,
        ),
      ),
    );
  }
}

class _ReflectionChipWidget extends StatefulWidget {
  final ReflectionChip chip;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReflectionChipWidget({
    required this.chip,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ReflectionChipWidget> createState() => _ReflectionChipWidgetState();
}

class _ReflectionChipWidgetState extends State<_ReflectionChipWidget> {
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
    final chip = widget.chip;
    final isSelected = widget.isSelected;
    final accentColor = chip.accentColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : ZenTheme.creamWhite.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.35)
                  : ZenTheme.creamWhite.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.check, color: accentColor, size: 14),
                const SizedBox(width: 6),
              ],
              Text(
                chip.label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: isSelected ? accentColor : ZenTheme.softGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseCheckIcon extends StatefulWidget {
  const _PulseCheckIcon();

  @override
  State<_PulseCheckIcon> createState() => _PulseCheckIconState();
}

class _PulseCheckIconState extends State<_PulseCheckIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ZenTheme.sageGreen.withValues(alpha: 0.08),
          border: Border.all(
            color: ZenTheme.sageGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: ZenTheme.sageGreen.withValues(alpha: 0.05),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.check, color: ZenTheme.sageGreen, size: 32),
      ),
    );
  }
}
