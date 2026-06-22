import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../bloc/confessional_bloc.dart';
import '../widgets/confessional_particle_effect.dart';

class ConfessionalView extends StatefulWidget {
  const ConfessionalView({super.key});

  @override
  State<ConfessionalView> createState() => _ConfessionalViewState();
}

class _ConfessionalViewState extends State<ConfessionalView> {
  final _controller = TextEditingController();
  bool _isBurning = false;
  bool _isCompleted = false;

  void _burnConfession() {
    if (_controller.text.trim().isEmpty) return;
    
    // Kích hoạt hiệu ứng hạt bay trước
    setState(() {
      _isBurning = true;
    });
  }

  void _onBurnComplete() {
    final confBloc = BlocProvider.of<ConfessionalBloc>(context);
    
    // Đốt xong thì dispatch Event lưu lên Firestore/Mock
    confBloc.add(SubmitConfessionRequested(_controller.text.trim()));
  }

  @override
  void dispose() {
    _controller.dispose();
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
          "Phòng Xưng Tội",
          style: textTheme.titleLarge!.copyWith(fontFamily: 'Lora', fontWeight: FontWeight.normal),
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
            child: BlocConsumer<ConfessionalBloc, ConfessionalState>(
              listener: (context, state) {
                if (state is ConfessionalSuccess) {
                  setState(() {
                    _isBurning = false;
                    _isCompleted = true;
                    _controller.clear();
                  });
                }
                
                if (state is ConfessionalFailure) {
                  setState(() {
                    _isBurning = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: ZenTheme.mistRed),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is ConfessionalLoading;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _isCompleted
                      ? _buildSuccessView(textTheme)
                      : _buildWriteView(textTheme, isLoading || _isBurning),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteView(TextTheme textTheme, bool isLocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Hãy trút bỏ gánh nặng tiêu cực",
          textAlign: TextAlign.center,
          style: textTheme.titleLarge!.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          "Viết ra tổn thương, lo âu hay lỗi lầm của bạn hoàn toàn ẩn danh. Sau đó, hãy 'hóa tro' để giải thoát chúng vào hư vô.",
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        
        Expanded(
          child: ConfessionalParticleEffect(
            isBurning: _isBurning,
            onComplete: _onBurnComplete,
            child: GlassContainer(
              opacity: 0.05,
              radius: 28,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.nights_stay_outlined, color: ZenTheme.mistRed, size: 24),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      enabled: !isLocked,
                      style: const TextStyle(color: ZenTheme.creamWhite, height: 1.5, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Hãy thành thật với chính mình. Không ai phán xét bạn ở đây...",
                        hintStyle: TextStyle(color: ZenTheme.softGray.withOpacity(0.4)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        if (!isLocked)
          ZenButton(
            text: "Hóa Tro & Giải Thoát",
            icon: Icons.local_fire_department,
            onPressed: () {
              if (_controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hãy viết điều gì đó trước khi hóa tro.")),
                );
                return;
              }
              _burnConfession();
            },
          )
        else if (_isBurning)
          const Center(child: CircularProgressIndicator(color: ZenTheme.mistRed)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSuccessView(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZenTheme.sageGreen.withOpacity(0.08),
              border: Border.all(
                color: ZenTheme.sageGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: ZenTheme.sageGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Đã Hòa Tan Thành Tro Bụi",
            style: textTheme.displayMedium!.copyWith(fontSize: 22, color: ZenTheme.creamWhite),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Nỗi buồn của bạn đã được giải thoát. Hãy hít một hơi thật sâu, thở ra thật chậm, cảm nhận sự nhẹ nhõm bên trong tâm hồn.",
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge!.copyWith(color: ZenTheme.softGray),
            ),
          ),
          const SizedBox(height: 48),
          
          ZenButton(
            text: "Quay về chốn cũ",
            isSecondary: true,
            onPressed: () {
              setState(() {
                _isCompleted = false;
              });
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Về Bếp Lửa chính", style: TextStyle(color: ZenTheme.sageGreen)),
          ),
        ],
      ),
    );
  }
}
