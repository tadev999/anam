import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/zen_button.dart';
import '../../bloc/auth_bloc.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = BlocProvider.of<AuthBloc>(context);

    if (_isSignUp) {
      authBloc.add(
        SignUpRequested(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    } else {
      authBloc.add(
        SignInRequested(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Nền Gradient Dark Luxury chuẩn an_match
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    Color(0xFF131A26),
                    Color(0xFF182232),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Vòng sáng hổ phách ấm áp mờ nhẹ góc trên trái
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Vòng sáng radar teal mờ nhẹ góc dưới phải
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.radarActive.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Brand Logo với Gradient và Glow ấm áp
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      "anam",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Không gian an trú • Chữa lành tâm hồn",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card Form xác thực
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        } else if (state is PasswordResetSent) {
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(
                                  color: AppColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              title: Row(
                                children: [
                                  const Icon(
                                    Icons.mark_email_read_outlined,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Đã gửi email khôi phục",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                "Liên kết đặt lại mật khẩu đã được gửi tới ${state.email}.\n\nVui lòng kiểm tra hộp thư của bạn (bao gồm cả thư mục Spam/Rác nếu không thấy trong Hộp thư đến).",
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(dialogCtx).pop(),
                                  child: Text(
                                    "Đã hiểu",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;

                        return GlassContainer(
                          radius: 24,
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _isSignUp
                                      ? "Tạo tài khoản mới"
                                      : "Trở về chốn bình yên",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                if (_isSignUp) ...[
                                  TextFormField(
                                    controller: _nameController,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                    ),
                                    enabled: !isLoading,
                                    decoration: _inputDecoration(
                                      "Tên hiển thị / Biệt danh",
                                      Icons.person_outline_rounded,
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? "Vui lòng nhập tên"
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                TextFormField(
                                  controller: _emailController,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textPrimary,
                                  ),
                                  enabled: !isLoading,
                                  decoration: _inputDecoration(
                                    "Địa chỉ email",
                                    Icons.email_outlined,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) => v == null || !v.contains('@')
                                      ? "Email không hợp lệ"
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _passwordController,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textPrimary,
                                  ),
                                  enabled: !isLoading,
                                  decoration: _inputDecoration(
                                    "Mật khẩu",
                                    Icons.lock_outline_rounded,
                                  ),
                                  obscureText: true,
                                  validator: (v) => v == null || v.length < 6
                                      ? "Mật khẩu tối thiểu 6 ký tự"
                                      : null,
                                ),

                                if (!_isSignUp) ...[
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : () => _showForgotPasswordDialog(
                                              context,
                                            ),
                                      child: Text(
                                        "Quên mật khẩu?",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else
                                  const SizedBox(height: 24),

                                ZenButton(
                                  text: _isSignUp
                                      ? "Bắt đầu hành trình"
                                      : "Bước vào không gian an trú",
                                  isLoading: isLoading,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: 16),

                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _isSignUp = !_isSignUp;
                                          });
                                        },
                                  child: Text(
                                    _isSignUp
                                        ? "Đã có tài khoản? Đăng nhập"
                                        : "Chưa có tài khoản? Đăng ký ngay",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.primary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext parentContext) {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: AppColors.glassBorder,
              width: 1,
            ),
          ),
          title: Text(
            "Khôi phục mật khẩu",
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nhập email đã đăng ký của bạn để nhận liên kết đặt lại mật khẩu.",
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration("Địa chỉ email", Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@')
                      ? "Email không hợp lệ"
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Hủy",
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final email = resetEmailController.text.trim();
                  BlocProvider.of<AuthBloc>(
                    parentContext,
                  ).add(PasswordResetRequested(email));
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                "Gửi liên kết",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, [IconData? icon]) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.textMuted, size: 20)
          : null,
      labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}
