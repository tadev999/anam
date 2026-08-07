import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/auth_repository.dart';
import '../data/models/user_model.dart';

// ==========================================
// 1. EVENTS
// ==========================================
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String displayName;
  final String email;
  final String password;
  const SignUpRequested(this.displayName, this.email, this.password);
  @override
  List<Object?> get props => [displayName, email, password];
}

class SignOutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class EmpathyPointsUpdated extends AuthEvent {
  final int points;
  const EmpathyPointsUpdated(this.points);
  @override
  List<Object?> get props => [points];
}

class StreakUpdated extends AuthEvent {
  final int streak;
  final String date;
  const StreakUpdated(this.streak, this.date);
  @override
  List<Object?> get props => [streak, date];
}

class _AuthUserChanged extends AuthEvent {
  final UserModel? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

// ==========================================
// 2. STATES
// ==========================================
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String email;
  const PasswordResetSent(this.email);
  @override
  List<Object?> get props => [email];
}

// ==========================================
// 3. BLOC IMPLEMENTATION
// ==========================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final BaseAuthRepository _authRepository;
  StreamSubscription<UserModel?>? _authSubscription;

  AuthBloc({required BaseAuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    // Đăng ký nhận sự kiện
    on<AppStarted>(_onAppStarted);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<EmpathyPointsUpdated>(_onEmpathyPointsUpdated);
    on<StreakUpdated>(_onStreakUpdated);
    on<_AuthUserChanged>(_onAuthUserChanged);

    // Lắng nghe thay đổi xác thực từ Repository stream
    _authSubscription = _authRepository.onAuthStateChanged.listen((user) {
      add(_AuthUserChanged(user));
    });
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthFailure("Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(event.displayName, event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthFailure("Đăng ký thất bại. Vui lòng thử lại."));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onEmpathyPointsUpdated(EmpathyPointsUpdated event, Emitter<AuthState> emit) async {
    await _authRepository.updateEmpathyPoints(event.points);
  }

  Future<void> _onStreakUpdated(StreakUpdated event, Emitter<AuthState> emit) async {
    await _authRepository.updateStreak(event.streak, event.date);
  }

  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onPasswordResetRequested(PasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(event.email);
      emit(PasswordResetSent(event.email));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
