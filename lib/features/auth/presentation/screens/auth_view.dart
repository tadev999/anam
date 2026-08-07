import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme.dart';
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
      authBloc.add(SignUpRequested(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ));
    } else {
      authBloc.add(SignInRequested(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ));
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Nền Gradient Zen dịu mát
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ZenTheme.slateDark,
                    Color(0xff121921),
                    Color(0xff18222d),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Các đốm sáng mờ nhẹ ở nền
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZenTheme.sageGreen.withOpacity(0.05),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ZenTheme.sageGreen.withOpacity(0.3),
                        width: 1.5,
                      ),
                      color: ZenTheme.sageGreen.withOpacity(0.05),
                    ),
                    child: const Icon(
                      Icons.filter_vintage_outlined,
                      color: ZenTheme.sageGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    "anam",
                    style: textTheme.displayLarge!.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w300,
                      color: ZenTheme.creamWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Không gian an trú chữa lành tâm hồn",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Lắng nghe và cập nhật giao diện thông qua BlocConsumer
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: ZenTheme.mistRed,
                          ),
                        );
                      } else if (state is PasswordResetSent) {
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            backgroundColor: ZenTheme.slateDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: ZenTheme.sageGreen.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.mark_email_read_outlined, color: ZenTheme.sageGreen, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  "Đã gửi email khôi phục",
                                  style: TextStyle(color: ZenTheme.creamWhite, fontSize: 18),
                                ),
                              ],
                            ),
                            content: Text(
                              "Liên kết đặt lại mật khẩu đã được gửi tới ${state.email}.\n\nVui lòng kiểm tra hộp thư của bạn (bao gồm cả thư mục Spam/Rác nếu không thấy trong Hộp thư đến).",
                              style: const TextStyle(color: ZenTheme.softGray, fontSize: 14, height: 1.4),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ZenTheme.sageGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => Navigator.of(dialogCtx).pop(),
                                child: const Text(
                                  "Đã hiểu",
                                  style: TextStyle(color: ZenTheme.slateDark, fontWeight: FontWeight.bold),
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
                        radius: 28,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isSignUp ? "Tạo tài khoản mới" : "Trở về chốn bình yên",
                                textAlign: TextAlign.center,
                                style: textTheme.titleLarge!.copyWith(
                                  color: ZenTheme.creamWhite,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              if (_isSignUp) ...[
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(color: ZenTheme.creamWhite),
                                  enabled: !isLoading,
                                  decoration: _inputDecoration("Tên hiển thị / Biệt danh"),
                                  validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập tên" : null,
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: ZenTheme.creamWhite),
                                enabled: !isLoading,
                                decoration: _inputDecoration("Địa chỉ email"),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => v == null || !v.contains('@') ? "Email không hợp lệ" : null,
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: ZenTheme.creamWhite),
                                enabled: !isLoading,
                                decoration: _inputDecoration("Mật khẩu"),
                                obscureText: true,
                                validator: (v) => v == null || v.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
                              ),
                              
                              if (!_isSignUp) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: isLoading ? null : () => _showForgotPasswordDialog(context),
                                    child: const Text(
                                      "Quên mật khẩu?",
                                      style: TextStyle(
                                        color: ZenTheme.softGray,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else
                                const SizedBox(height: 24),
                              
                              ZenButton(
                                text: _isSignUp ? "Bắt đầu hành trình" : "Bước vào không gian an trú",
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
                                  style: const TextStyle(
                                    color: ZenTheme.sageGreen,
                                    fontSize: 13,
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
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext parentContext) {
    final resetEmailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ZenTheme.slateDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: ZenTheme.sageGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: const Text(
            "Khôi phục mật khẩu",
            style: TextStyle(color: ZenTheme.creamWhite, fontSize: 18),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nhập email đã đăng ký của bạn để nhận liên kết đặt lại mật khẩu.",
                  style: TextStyle(color: ZenTheme.softGray, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: resetEmailController,
                  style: const TextStyle(color: ZenTheme.creamWhite),
                  decoration: _inputDecoration("Địa chỉ email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || !v.contains('@') ? "Email không hợp lệ" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                "Hủy",
                style: TextStyle(color: ZenTheme.softGray),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ZenTheme.sageGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final email = resetEmailController.text.trim();
                  BlocProvider.of<AuthBloc>(parentContext).add(PasswordResetRequested(email));
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text(
                "Gửi liên kết",
                style: TextStyle(color: ZenTheme.slateDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ZenTheme.softGray),
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: ZenTheme.creamWhite.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: ZenTheme.creamWhite.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ZenTheme.sageGreen, width: 1.0),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
