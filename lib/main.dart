import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/database_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/auth_view.dart';
import 'features/home/presentation/screens/home_view.dart';
import 'features/daily_ritual/bloc/ritual_bloc.dart';
import 'features/confessional/bloc/confessional_bloc.dart';
import 'features/tribe/bloc/tribe_bloc.dart';
import 'features/monastery/bloc/monastery_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ĐẶT THÀNH true NẾU BẠN MUỐN BẮT BUỘC CHẠY MOCK OFFLINE ĐỂ TEST GIAO DIỆN
  bool forceMockMode = false;

  // KHỞI TẠO HỆ THỐNG AN TOÀN (SAFE BOOTSTRAP)
  bool useFirebase = false;
  
  if (!forceMockMode) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      useFirebase = true;
      debugPrint("Anam khởi tạo thành công ở chế độ Real Firebase!");
    } catch (e) {
      debugPrint("Anam đang chạy ở chế độ Mock Offline (Chưa cấu hình Firebase): $e");
    }
  } else { // ignore: dead_code
    debugPrint("Anam đang chạy ở chế độ BẮT BUỘC MOCK OFFLINE theo yêu cầu cấu hình.");
  }

  // Khởi tạo các repositories tương ứng
  final authRepository = useFirebase ? FirebaseAuthRepository() : MockAuthRepository();
  final databaseRepository = useFirebase ? FirebaseDatabaseRepository() : MockDatabaseRepository();
  
  await databaseRepository.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BaseAuthRepository>.value(value: authRepository),
        RepositoryProvider<BaseDatabaseRepository>.value(value: databaseRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<BaseAuthRepository>(context),
            )..add(AppStarted()),
          ),
          BlocProvider<RitualBloc>(
            create: (context) => RitualBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(context),
            ),
          ),
          BlocProvider<ConfessionalBloc>(
            create: (context) => ConfessionalBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(context),
            ),
          ),
          BlocProvider<TribeBloc>(
            create: (context) => TribeBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(context),
            ),
          ),
          BlocProvider<MonasteryBloc>(
            create: (context) => MonasteryBloc(),
          ),
        ],
        child: const AnamApp(),
      ),
    ),
  );
}

class AnamApp extends StatelessWidget {
  const AnamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anam - Secular Sanctuary',
      theme: ZenTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const HomeView();
          }
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: ZenTheme.sageGreen),
              ),
            );
          }
          // Mặc định trả về màn hình đăng nhập nếu chưa xác thực
          return const AuthView();
        },
      ),
    );
  }
}
