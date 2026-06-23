import 'dart:async';
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
  bool _isFocusMode = false;
  bool _showFlowReminder = false;
  bool _isDissolving = false;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _prompt = _selectPromptByMindState();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  String _selectPromptByMindState() {
    final dbRepo = RepositoryProvider.of<BaseDatabaseRepository>(context, listen: false);
    final mindState = dbRepo.currentMindState;

    if (mindState == 'burnout_state') {
      return ZenConstants.reflectionPrompts[3];
    } else if (mindState == 'overthinking_state') {
      return ZenConstants.reflectionPrompts[4];
    } else if (mindState == 'lonely_state') {
      return ZenConstants.reflectionPrompts[5];
    } else if (mindState == 'empty_state') {
      return ZenConstants.reflectionPrompts[6];
    } else {
      // Pick random from the core questions
      final randomIdx = DateTime.now().millisecond % 3;
      return ZenConstants.reflectionPrompts[randomIdx];
    }
  }

  void _onTextChanged() {
    final text = _controller.text;
    
    // Auto-activate Focus Mode when typing starts
    if (text.isNotEmpty && !_isFocusMode) {
      setState(() {
        _isFocusMode = true;
      });
    } else if (text.isEmpty && _isFocusMode) {
      setState(() {
        _isFocusMode = false;
      });
    }

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
    if (!_focusNode.hasFocus) {
      setState(() {
        _isFocusMode = false;
      });
    }
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
      body: BlocListener<ReflectionBloc, ReflectionState>(
        listener: (context, state) {
          if (state is ReflectionSuccess) {
            // Reward +5 EP on success
            BlocProvider.of<AuthBloc>(context).add(const EmpathyPointsUpdated(5));
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.outfit(color: ZenTheme.creamWhite),
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
                  style: GoogleFonts.outfit(color: ZenTheme.creamWhite),
                ),
                backgroundColor: ZenTheme.mistRed.withOpacity(0.8),
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
              child: GestureDetector(
                onTap: () {
                  // Exit focus mode on clicking background
                  _focusNode.unfocus();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header HUD (Fades out in focus mode)
                      AnimatedOpacity(
                        opacity: _isFocusMode ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: ZenTheme.creamWhite),
                              onPressed: _isFocusMode ? null : () => Navigator.pop(context),
                            ),
                            const Spacer(),
                            Text(
                              "Gương Tự Vấn",
                              style: textTheme.displaySmall!.copyWith(
                                fontSize: 14,
                                color: ZenTheme.sageGreen,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 48), // Balancing back button spacing
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Prompt Question Card
                      Text(
                        "Câu hỏi tự vấn hôm nay",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: ZenTheme.softGray.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "\"$_prompt\"",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                            color: ZenTheme.creamWhite,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Text Editor Area wrapped with Particle dissolution
                      Expanded(
                        child: ReleaseParticleEffect(
                          isBurning: _isDissolving,
                          onComplete: () {
                            // After dissolution, trigger bloc to discard and exit
                            BlocProvider.of<ReflectionBloc>(context).add(
                              const DiscardReflectionRequested(),
                            );
                          },
                          child: Stack(
                            children: [
                              TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                maxLines: null,
                                cursorColor: ZenTheme.sageGreen,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  color: ZenTheme.creamWhite.withOpacity(0.9),
                                  height: 1.6,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Nhập những suy nghĩ chân thật nhất của bạn...\nHãy viết tự do không bộ lọc...",
                                  hintStyle: GoogleFonts.outfit(
                                    fontSize: 15,
                                    color: ZenTheme.softGray.withOpacity(0.4),
                                    height: 1.6,
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
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "Đừng lo lắng về câu từ hay ngữ pháp, cứ để dòng suy nghĩ tuôn chảy tự do...",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
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

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 16),

                      // Bottom actions HUD (Fades out in focus mode)
                      AnimatedOpacity(
                        opacity: _isFocusMode ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Character count validation feedback
                            if (_controller.text.trim().length < 50 && _controller.text.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "Cần nhập thêm ${50 - _controller.text.trim().length} ký tự để hoàn tất tự vấn.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: ZenTheme.softGold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                            // Dual button options
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isFocusMode || _isDissolving ? null : _handleVoidRelease,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ZenTheme.mistRed,
                                      side: const BorderSide(color: ZenTheme.mistRed, width: 1.0),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: Text(
                                      "Gửi vào hư vô",
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ZenButton(
                                    text: "Cất vào góc riêng",
                                    onPressed: _isFocusMode || _isDissolving ? null : _handleSaveLocal,
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

  void _handleVoidRelease() {
    if (_controller.text.trim().length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Chiêm nghiệm tự vấn cần đạt tối thiểu 50 ký tự để gửi vào hư vô.",
            style: GoogleFonts.outfit(color: ZenTheme.creamWhite),
          ),
          backgroundColor: ZenTheme.mistRed.withOpacity(0.8),
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
            "Chiêm nghiệm tự vấn cần đạt tối thiểu 50 ký tự để cất vào nhật ký.",
            style: GoogleFonts.outfit(color: ZenTheme.creamWhite),
          ),
          backgroundColor: ZenTheme.mistRed.withOpacity(0.8),
        ),
      );
      return;
    }

    _focusNode.unfocus();
    BlocProvider.of<ReflectionBloc>(context).add(
      SaveReflectionRequested(prompt: _prompt, content: _controller.text),
    );
  }
}
