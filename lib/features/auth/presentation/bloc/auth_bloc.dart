import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  SignUpRequested(this.email, this.password, this.name);
}

class SignOut extends AuthEvent {}

class SignInWithGoogle extends AuthEvent {}

class UpdateProfilePhoto extends AuthEvent {
  final String path;
  UpdateProfilePhoto(this.path);
}

class UpdateUsernameRequested extends AuthEvent {
  final String name;
  UpdateUsernameRequested(this.name);
}

class UpdateEmailRequested extends AuthEvent {
  final String email;
  UpdateEmailRequested(this.email);
}

class UpdatePasswordRequested extends AuthEvent {
  final String password;
  UpdatePasswordRequested(this.password);
}

class DeleteAccountRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

// States
abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class SignUpSuccess extends AuthState {}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(Unauthenticated()) {
    on<CheckAuthStatus>((event, emit) async {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signIn(event.email, event.password);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(AuthError("Invalid credentials"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.signUp(event.email, event.password, event.name);
        emit(SignUpSuccess());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOut>((event, emit) async {
      await _authRepository.signOut();
      emit(Unauthenticated());
    });

    on<SignInWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await _authRepository.signInWithGoogle();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<UpdateProfilePhoto>((event, emit) async {
      await _authRepository.updateProfilePhoto(event.path);
      add(CheckAuthStatus());
    });

    on<UpdateUsernameRequested>((event, emit) async {
      await _authRepository.updateDisplayName(event.name);
      add(CheckAuthStatus());
    });

    on<UpdateEmailRequested>((event, emit) async {
      await _authRepository.updateEmail(event.email);
      add(CheckAuthStatus());
    });

    on<UpdatePasswordRequested>((event, emit) async {
      await _authRepository.updatePassword(event.password);
      add(CheckAuthStatus());
    });

    on<DeleteAccountRequested>((event, emit) async {
      await _authRepository.deleteAccount();
      emit(Unauthenticated());
    });
  }
}
