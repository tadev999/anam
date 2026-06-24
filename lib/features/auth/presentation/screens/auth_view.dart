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
