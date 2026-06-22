import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/data/models/user_model.dart';
import '../../bloc/tribe_bloc.dart';

class TribeView extends StatefulWidget {
  const TribeView({super.key});

  @override
  State<TribeView> createState() => _TribeViewState();
}

class _TribeViewState extends State<TribeView> {
  @override
  void initState() {
    super.initState();
    _loadConfessions();
  }

  void _loadConfessions() {
    BlocProvider.of<TribeBloc>(context).add(LoadConfessionsRequested());
  }

  void _sendHug(String confessionId) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final uid = (authBloc.state is Authenticated)
        ? (authBloc.state as Authenticated).user.uid
        : '';
        
    BlocProvider.of<TribeBloc>(context).add(SendHugRequested(confessionId, uid));
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
          "Bộ Lạc Thấu Cảm",
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
            child: BlocConsumer<TribeBloc, TribeState>(
              listener: (context, state) {
                // Thưởng điểm thấu cảm cho AuthBloc khi gửi cái ôm thành công
                if (state is TribeLoaded && state.justSupportedConfessionId != null) {
                  BlocProvider.of<AuthBloc>(context).add(const EmpathyPointsUpdated(2));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã gửi hơi ấm thấu cảm của bạn. +2 EP!"),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
                
                if (state is TribeFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: ZenTheme.mistRed),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is TribeLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildEmpathySummary(textTheme, user),
                    const SizedBox(height: 16),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Hãy sưởi ấm những tâm hồn cô đơn",
                        style: textTheme.titleLarge!.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: ZenTheme.sageGreen))
                          : state is TribeLoaded && state.confessions.isEmpty
                              ? _buildEmptyState(textTheme)
                              : state is TribeLoaded
                                  ? ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      itemCount: state.confessions.length,
                                      itemBuilder: (context, index) {
                                        final confession = state.confessions[index];
                                        final hasSupported = confession.supportedUserUids.contains(user?.uid);
                                        
                                        return GlassContainer(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          opacity: 0.04,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                confession.content,
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
                                                    _formatTimeAgo(confession.timestamp),
                                                    style: textTheme.bodyMedium!.copyWith(
                                                      fontSize: 11,
                                                      color: ZenTheme.softGray.withOpacity(0.5),
                                                    ),
                                                  ),
                                                  
                                                  GestureDetector(
                                                    onTap: hasSupported ? null : () => _sendHug(confession.id),
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
                                                                ? "Đã sưởi ấm (${confession.hugCount})"
                                                                : "Sưởi ấm (${confession.hugCount})",
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
                  "Tích luỹ 50 EP để thăng cấp lên Keepers, đi sưởi ấm cho các linh hồn cô đơn.",
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
          Text("Bộ lạc hiện rất bình yên", style: textTheme.titleLarge!.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          const Text("Chưa có lời xưng tội nào cần được sưởi ấm.", style: TextStyle(color: ZenTheme.softGray)),
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
