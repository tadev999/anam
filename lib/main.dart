import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'core/repositories/auth_repository.dart';
import 'core/repositories/database_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/auth_view.dart';
import 'features/navigation/presentation/screens/main_navigation_page.dart';
import 'features/daily_anchor/bloc/anchor_bloc.dart';
import 'features/release_space/bloc/release_bloc.dart';
import 'features/hearth/bloc/hearth_bloc.dart';
import 'features/silence/bloc/silence_bloc.dart';
import 'features/sleep_seed/bloc/sleep_seed_bloc.dart';
import 'features/mind_garden/bloc/mind_garden_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // KHỞI TẠO HỆ THỐNG AN TOÀN (SAFE BOOTSTRAP)
  bool useFirebase = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    useFirebase = true;
    debugPrint("Anam khởi tạo thành công ở chế độ Real Firebase!");
  } catch (e) {
    debugPrint(
      "Anam đang chạy ở chế độ Mock Offline (Chưa cấu hình Firebase): $e",
    );
  }

  // Khởi tạo các repositories tương ứng
  final authRepository = useFirebase
      ? FirebaseAuthRepository()
      : MockAuthRepository();
  final databaseRepository = useFirebase
      ? FirebaseDatabaseRepository()
      : MockDatabaseRepository();

  await databaseRepository.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BaseAuthRepository>.value(value: authRepository),
        RepositoryProvider<BaseDatabaseRepository>.value(
          value: databaseRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<BaseAuthRepository>(
                context,
              ),
            )..add(AppStarted()),
          ),
          BlocProvider<AnchorBloc>(
            create: (context) => AnchorBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
          ),
          BlocProvider<ReleaseBloc>(
            create: (context) => ReleaseBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
          ),
          BlocProvider<HearthBloc>(
            create: (context) => HearthBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
          ),
          BlocProvider<SilenceBloc>(create: (context) => SilenceBloc()),
          BlocProvider<SleepSeedBloc>(
            create: (context) => SleepSeedBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
          ),
          BlocProvider<MindGardenBloc>(
            create: (context) => MindGardenBloc(
              databaseRepository: RepositoryProvider.of<BaseDatabaseRepository>(
                context,
              ),
            ),
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
      theme: ZenTheme.lightTheme,
      darkTheme: ZenTheme.darkTheme,
      themeMode: ZenTheme.getCircadianThemeMode(),
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const MainNavigationPage();
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
