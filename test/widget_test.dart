import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anam/main.dart';
import 'package:anam/core/repositories/auth_repository.dart';
import 'package:anam/core/repositories/database_repository.dart';
import 'package:anam/features/auth/bloc/auth_bloc.dart';
import 'package:anam/features/daily_anchor/bloc/anchor_bloc.dart';
import 'package:anam/features/release_space/bloc/release_bloc.dart';
import 'package:anam/features/hearth/bloc/hearth_bloc.dart';
import 'package:anam/features/silence/bloc/silence_bloc.dart';

void main() {
  testWidgets('AnamApp Smoke Test', (WidgetTester tester) async {
    // Khởi tạo các Mock Repository kiểm thử
    final authRepository = MockAuthRepository();
    final databaseRepository = MockDatabaseRepository();
    
    // Mock dữ liệu SharedPreferences trước khi chạy
    SharedPreferences.setMockInitialValues({});
    await databaseRepository.init();

    // Pump widget với đầy đủ RepositoryProvider và MultiBlocProvider
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BaseAuthRepository>.value(value: authRepository),
          RepositoryProvider<BaseDatabaseRepository>.value(value: databaseRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(authRepository: authRepository)..add(AppStarted()),
            ),
            BlocProvider<AnchorBloc>(
              create: (context) => AnchorBloc(databaseRepository: databaseRepository),
            ),
            BlocProvider<ReleaseBloc>(
              create: (context) => ReleaseBloc(databaseRepository: databaseRepository),
            ),
            BlocProvider<HearthBloc>(
              create: (context) => HearthBloc(databaseRepository: databaseRepository),
            ),
            BlocProvider<SilenceBloc>(
              create: (context) => SilenceBloc(),
            ),
          ],
          child: const AnamApp(),
        ),
      ),
    );

    // Chờ hệ thống khởi chạy giao diện xong
    await tester.pumpAndSettle();

    // Kiểm tra xem nhãn chào mừng 'anam' có hiển thị chính xác không
    expect(find.text('anam'), findsOneWidget);
  });
}
