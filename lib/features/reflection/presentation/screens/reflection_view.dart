import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../core/repositories/database_repository.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../release_space/presentation/widgets/release_particle_effect.dart';
import '../../bloc/reflection_bloc.dart';

class ReflectionView extends StatefulWidget {
  const ReflectionView({super.key});

  @override
  State<ReflectionView> createState() => _ReflectionViewState();
}

class _ReflectionViewState extends State<ReflectionView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late String _prompt;
  int? _selectedCircuitId; // null = auto theo mindState
  bool _isCircuitSelecting = true; // Bước 1: chọn Mạch
  bool _isFocusMode = false;
  bool _showFlowReminder = false;
  bool _isDissolving = false;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _prompt = _selectPromptByMindState(null); // auto at start

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  String _selectPromptByMindState(int? circuitId) {
    // Nếu chọn mạch cụ thể, lấy từ wisdomFlashcards
    if (circuitId != null) {
      final cards = ZenConstants.wisdomFlashcards
          .where((c) => c['circuit'] == circuitId)
          .toList();
      if (cards.isNotEmpty) {
        final card = cards[Random().nextInt(cards.length)];
        return card['question'] as String;
      }
    }

    // Auto: dựa theo mindState
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(
      context,
      listen: false,
    );
    final mindState = dbRepo.currentMindState;
    final random = Random();

    List<String> pool;
    if (mindState == 'burnout_state') {
      pool = ZenConstants.reflectionPrompts['burnout'] ?? [];
    } else if (mindState == 'overthinking_state') {
      pool = ZenConstants.reflectionPrompts['overthinking'] ?? [];
    } else if (mindState == 'lonely_state') {
      pool = ZenConstants.reflectionPrompts['lonely'] ?? [];
    } else if (mindState == 'empty_state') {
      pool = ZenConstants.reflectionPrompts['empty'] ?? [];
    } else {
      pool = ZenConstants.reflectionPrompts['peaceful'] ?? [];
    }

    if (pool.isEmpty) {
      return "Bạn là ai khi không có ai nhìn?";
    }
    return pool[random.nextInt(pool.length)];
  }

  void _onTextChanged() {
    final text = _controller.text;

    setState(() {});

    // Flow State Timer: if stops writing for 10s, show hint
    _inactivityTimer?.cancel();
    if (_showFlowReminder) {
      setState(() {
        _showFlowReminder = false;
      });
    }

    if (text.isNotEmpty) {
      _inactivityTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && _controller.text.isNotEmpty && _focusNode.hasFocus) {
          setState(() {
            _showFlowReminder = true;
          });
        }
      });
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isFocusMode = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _isFocusMode ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: ZenTheme.creamWhite,
                size: 20,
              ),
              onPressed: _isFocusMode ? null : () => Navigator.pop(context),
            ),
            title: Text(
              "Gương tự vấn",
              style: textTheme.titleLarge!.copyWith(
                fontFamily: 'Lora',
                fontWeight: FontWeight.normal,
                color: ZenTheme.creamWhite,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: BlocListener<ReflectionBloc, ReflectionState>(
        listener: (context, state) {
          if (state is ReflectionSuccess) {
            // Reward +5 EP on success
            BlocProvider.of<AuthBloc>(
              context,
            ).add(const EmpathyPointsUpdated(5));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.nunito(color: ZenTheme.creamWhite),
                ),
                backgroundColor: ZenTheme.slateDark,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          } else if (state is ReflectionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error,
                  style: GoogleFonts.nunito(color: ZenTheme.creamWhite),
                ),
                backgroundColor: ZenTheme.mistRed.withValues(alpha: 0.8),
              ),
            );
          }
        },
        child: Stack(
          children: [
            // Zen background
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
              child: _isCircuitSelecting
                  ? _buildCircuitSelector()
                  : GestureDetector(
                      onTap: () => _focusNode.unfocus(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Circuit Badge (nếu đã chọn Mạch)
                            if (_selectedCircuitId != null) ...[
                              _buildCircuitBadgeWidget(),
                              const SizedBox(height: 10),
                            ],

                            // Prompt Question Card
                            AnimatedOpacity(
                              opacity: _isFocusMode ? 0.3 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                children: [
                                  Text(
                                    "Câu hỏi tự thấu hiểu hôm nay",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: ZenTheme.softGray.withValues(alpha: 0.6),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      "\"$_prompt\"",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lora(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: ZenTheme.creamWhite,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),


                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Text Editor Area wrapped with Particle dissolution
                      Expanded(
                        child: ReleaseParticleEffect(
                          isBurning: _isDissolving,
                          onComplete: () {
                            // After dissolution, trigger bloc to discard and exit
                            BlocProvider.of<ReflectionBloc>(
                              context,
                            ).add(const DiscardReflectionRequested());
                          },
                          child: Stack(
                            children: [
                              TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                maxLines: null,
                                cursorColor: ZenTheme.sageGreen,
                                style: GoogleFonts.nunito(
                                  fontSize: 17,
                                   color: ZenTheme.creamWhite.withValues(alpha: 0.9),
                                  height: 1.65,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      "Nhập những suy nghĩ chân thật nhất...\nViết tự do không bộ lọc...",
                                  hintStyle: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: ZenTheme.softGray.withValues(alpha: 0.4),
                                    height: 1.65,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),

                              // Flow state warning indicator
                              Positioned(
                                bottom: 12,
                                left: 0,
                                right: 0,
                                child: AnimatedOpacity(
                                  opacity: _showFlowReminder ? 0.7 : 0.0,
                                  duration: const Duration(milliseconds: 450),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Đừng lo lắng về câu từ hay ngữ pháp, cứ để dòng suy nghĩ tuôn chảy tự do...",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunito(
                                        color: ZenTheme.softGold,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                key: const ValueKey('bottom_actions'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 16),
                                  const Divider(color: Colors.white10),
                                  const SizedBox(height: 16),
                                  // Character count validation feedback
                                  if (_controller.text.trim().length < 50 &&
                                      _controller.text.trim().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        "Cần nhập thêm ${50 - _controller.text.trim().length} ký tự để hoàn tất bài chiêm nghiệm.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                          color: ZenTheme.softGold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  // Dual button options stacked vertically to prevent right overflow
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ZenButton(
                                        text: "Cất vào góc riêng",
                                        onPressed: _isDissolving ? null : _handleSaveLocal,
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: _isDissolving ? null : _handleVoidRelease,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: ZenTheme.mistRed,
                                          side: const BorderSide(
                                            color: ZenTheme.mistRed,
                                            width: 1.0,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(28),
                                          ),
                                        ),
                                        child: Text(
                                          "Gửi vào hư vô",
                                          style: GoogleFonts.nunito(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircuitBadgeWidget() {
    final circuit = ZenConstants.endogenCircuits
        .firstWhere((c) => c['id'] == _selectedCircuitId);
    final color = Color(circuit['color'] as int);
    return GestureDetector(
      onTap: _isFocusMode
          ? null
          : () => setState(() => _isCircuitSelecting = true),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(circuit['icon'] as String, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
              Text(
                'Mạch ${circuit['id']} — ${circuit['name']}',
                style: GoogleFonts.nunito(
                  color: color,
                  fontSize: 10,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, color: color.withOpacity(0.5), size: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Circuit Selector Screen
  // ---------------------------------------------------------------------------
  Widget _buildCircuitSelector() {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(
            'Gương tự vấn',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge!.copyWith(
              fontFamily: 'Lora',
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn Mạch nội tâm bạn muốn khám phá hôm nay',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium!.copyWith(
              color: ZenTheme.softGray,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),

          // Circuit options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...ZenConstants.endogenCircuits.map((circuit) {
                    final color = Color(circuit['color'] as int);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCircuitId = circuit['id'] as int;
                          _prompt = _selectPromptByMindState(_selectedCircuitId);
                          _isCircuitSelecting = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: color.withOpacity(0.07),
                          border: Border.all(color: color.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          children: [
                            Text(circuit['icon'] as String, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mạch ${circuit['id']} — ${circuit['name']}',
                                    style: textTheme.titleLarge!.copyWith(
                                      fontSize: 14,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    circuit['desc'] as String,
                                    style: textTheme.bodyMedium!.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.5), size: 14),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  // Auto option
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCircuitId = null;
                        _prompt = _selectPromptByMindState(null);
                        _isCircuitSelecting = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: ZenTheme.creamWhite.withOpacity(0.04),
                        border: Border.all(color: ZenTheme.creamWhite.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome, color: ZenTheme.softGray, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Tự động theo tâm trạng của tôi',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: ZenTheme.softGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVoidRelease() {
    if (_controller.text.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Bài chiêm nghiệm cần đạt tối thiểu 50 ký tự để gửi vào hư vô.",
            style: GoogleFonts.nunito(color: ZenTheme.creamWhite),
          ),
          backgroundColor: ZenTheme.mistRed.withValues(alpha: 0.8),
        ),
      );
      return;
    }

    _focusNode.unfocus();
    setState(() {
      _isDissolving = true;
    });
  }

  void _handleSaveLocal() {
    if (_controller.text.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Bài chiêm nghiệm cần đạt tối thiểu 50 ký tự để cất vào nhật ký.",
            style: GoogleFonts.nunito(color: ZenTheme.creamWhite),
          ),
          backgroundColor: ZenTheme.mistRed.withValues(alpha: 0.8),
        ),
      );
      return;
    }

    _focusNode.unfocus();
    BlocProvider.of<ReflectionBloc>(
      context,
    ).add(SaveReflectionRequested(prompt: _prompt, content: _controller.text));
  }
}
