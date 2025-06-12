import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({AuthRepo? authRepo})
    : _authRepo = authRepo ?? AuthRepo(),
      super(AuthInitial());

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      final userCredential = await _authRepo.signInWithGoogle();
      if (userCredential.user != null) {
        emit(AuthSuccess(user: userCredential.user!));
      } else {
        emit(const AuthFailure('Failed to sign in with Google'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Sign in as guest
  Future<void> signInAsGuest() async {
    try {
      emit(AuthLoading());
      final userCredential = await _authRepo.signInAsGuest();
      if (userCredential.user != null) {
        emit(AuthSuccess(user: userCredential.user!, isGuest: true));
      } else {
        emit(const AuthFailure('Failed to sign in as guest'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepo.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  // Check current auth state
  void checkAuthState() {
    final user = _authRepo.currentUser;
    if (user != null) {
      emit(AuthSuccess(user: user, isGuest: user.isAnonymous));
    } else {
      emit(AuthInitial());
    }
  }
}
