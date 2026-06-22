import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../bloc/ritual_bloc.dart';

class RitualView extends StatefulWidget {
  const RitualView({super.key});

  @override
  State<RitualView> createState() => _RitualViewState();
}

class _RitualViewState extends State<RitualView> {
  int _currentStep = 0; // 0: Affirmation, 1: Offering, 2: Intention, 3: Completed
  
  late String _selectedAffirmation;
  String? _selectedOfferingId;
  final _intentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final rand = Random();
    _selectedAffirmation = ZenConstants.dailyAffirmations[rand.nextInt(ZenConstants.dailyAffirmations.length)];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayRitual();
    });
  }

  void _checkTodayRitual() {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final ritualBloc = BlocProvider.of<RitualBloc>(context);
    
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';
    final todayStr = _getTodayString();
    
    ritualBloc.add(CheckTodayRitualRequested(uid, todayStr));
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _finishRitual() {
    if (_intentionController.text.trim().isEmpty) return;

    final authBloc = BlocProvider.of<AuthBloc>(context);
    final ritualBloc = BlocProvider.of<RitualBloc>(context);
    
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';
    final date = _getTodayString();

    ritualBloc.add(CompleteTodayRitualRequested(
      uid: uid,
      date: date,
      affirmation: _selectedAffirmation,
      microOfferingId: _selectedOfferingId ?? 'water',
      intention: _intentionController.text.trim(),
    ));
  }

  @override
  void dispose() {
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
          icon: const Icon(Icons.arrow_back_ios, color: ZenTheme.creamWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Nghi Lễ Mỗi Ngày",
          style: textTheme.titleLarge!.copyWith(fontFamily: 'Lora', fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền Gradient tối sang trọng
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
            child: BlocConsumer<RitualBloc, RitualState>(
              listener: (context, state) {
                // Xử lý khi tải thành công trạng thái đã hoàn thành trước đó
                if (state is RitualLoadSuccess && state.ritual != null && state.ritual!.completed) {
                  setState(() {
                    _currentStep = 3;
                    _selectedAffirmation = state.ritual!.affirmationText;
                    _selectedOfferingId = state.ritual!.microOfferingId;
                    _intentionController.text = state.ritual!.intention;
                  });
                }
                
                // Xử lý khi hoàn thành mới nghi lễ
                if (state is RitualSubmissionSuccess) {
                  final authBloc = BlocProvider.of<AuthBloc>(context);
                  final offering = ZenConstants.microOfferings.firstWhere((o) => o['id'] == _selectedOfferingId);
                  final int pointsEarned = offering['points'] as int;
                  
                  // 1. Thưởng điểm thấu cảm EP cho Auth BLoC
                  authBloc.add(EmpathyPointsUpdated(pointsEarned));

                  // 2. Cập nhật Streak thiền định cho Auth BLoC
                  final currentStreak = (authBloc.state is Authenticated)
                      ? (authBloc.state as Authenticated).user.streak
                      : 0;
                  authBloc.add(StreakUpdated(currentStreak + 1, _getTodayString()));

                  setState(() {
                    _currentStep = 3;
                  });
                }
                
                if (state is RitualFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: ZenTheme.mistRed),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is RitualLoading;

                if (isLoading && _currentStep == 0) {
                  return const Center(child: CircularProgressIndicator(color: ZenTheme.sageGreen));
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

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final active = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: active ? ZenTheme.sageGreen : ZenTheme.creamWhite.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(TextTheme textTheme, bool isLoading) {
    switch (_currentStep) {
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

  Widget _buildAffirmationStep(TextTheme textTheme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "I. Nhận lời khuyên bảo",
          style: textTheme.bodyMedium!.copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        Text(
          "Lời nguyện chánh niệm dành riêng cho bạn hôm nay",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
        ),
        const SizedBox(height: 60),
        
        GlassContainer(
          opacity: 0.05,
          radius: 36,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.filter_vintage_outlined, color: ZenTheme.softGold, size: 24),
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
                "— Anam Breath",
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

  Widget _buildOfferingStep(TextTheme textTheme, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            "II. Hành Động Nhỏ (Micro-Offering)",
            style: textTheme.bodyMedium!.copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            "Chọn 1 hành động cực kỳ nhỏ để tìm lại động lực sống",
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
            
            return GestureDetector(
              onTap: isLoading
                  ? null
                  : () {
                      setState(() {
                        _selectedOfferingId = offering['id'];
                      });
                    },
              child: GlassContainer(
                margin: const EdgeInsets.only(bottom: 12),
                opacity: isSelected ? 0.12 : 0.05,
                border: Border.all(
                  color: isSelected ? ZenTheme.sageGreen : ZenTheme.creamWhite.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1.0,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? ZenTheme.sageGreen.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.spa_outlined,
                        color: isSelected ? ZenTheme.sageGreen : ZenTheme.softGray,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offering['title'],
                            style: textTheme.titleLarge!.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            offering['description'],
                            style: textTheme.bodyMedium!.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "+${offering['points']} EP",
                          style: const TextStyle(color: ZenTheme.softGold, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          offering['duration'],
                          style: const TextStyle(color: ZenTheme.softGray, fontSize: 11),
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

  Widget _buildIntentionStep(TextTheme textTheme, bool isLoading) {
    return Column(
      children: [
        Text(
          "III. Lời Nguyện Ước (Intention)",
          style: textTheme.bodyMedium!.copyWith(color: ZenTheme.sageGreen, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        Text(
          "Viết một điều duy nhất bạn muốn hoàn thành hôm nay để thấy ngày trôi qua có ý nghĩa",
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
                  hintText: "Ví dụ: 'Hôm nay, tôi muốn hoàn thành bài tập về nhà và mỉm cười với mọi người xung quanh.'",
                  hintStyle: TextStyle(color: ZenTheme.softGray.withOpacity(0.5), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
            border: Border.all(
              color: ZenTheme.sageGreen,
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.wb_sunny_outlined,
            color: ZenTheme.softGold,
            size: 40,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "Thánh Đường Đã Ghi Nhận",
          style: textTheme.displayMedium!.copyWith(fontSize: 22, color: ZenTheme.creamWhite),
        ),
        const SizedBox(height: 12),
        Text(
          "Cảm ơn bạn đã kết thúc nghi lễ hôm nay. Tâm hồn bạn đã được tiếp thêm năng lượng tích cực.",
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
                "Tóm tắt nghi lễ hôm nay:",
                style: TextStyle(color: ZenTheme.sageGreen, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow("Lời khuyên:", _selectedAffirmation),
              const Divider(color: Colors.white10),
              _buildSummaryRow(
                "Hành động nhỏ:",
                ZenConstants.microOfferings.firstWhere((o) => o['id'] == _selectedOfferingId)['title'],
              ),
              const Divider(color: Colors.white10),
              _buildSummaryRow("Nguyện ước:", _intentionController.text),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        ZenButton(
          text: "Trở về Bếp Lửa",
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
          Text(label, style: const TextStyle(color: ZenTheme.softGold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: ZenTheme.creamWhite, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ZenButton(
                text: "Quay lại",
                isSecondary: true,
                onPressed: isLoading ? null : () => setState(() => _currentStep--),
              ),
            ),
          )
        else
          const Spacer(),
          
        Expanded(
          child: ZenButton(
            text: _currentStep == 2 ? "Hoàn thành" : "Tiếp tục",
            isLoading: isLoading,
            onPressed: () {
              if (_currentStep == 1 && _selectedOfferingId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hãy chọn một hành động nhỏ để tiếp tục.")),
                );
                return;
              }
              if (_currentStep == 2) {
                _finishRitual();
              } else {
                setState(() => _currentStep++);
              }
            },
          ),
        ),
      ],
    );
  }
}
