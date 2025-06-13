import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/api/firebase_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseService _firebaseService;

  AuthCubit(this._firebaseService) : super(const AuthInitial());

  Future<void> signInWithGoogle() async {
    try {
      emit(AuthLoading());
      print('Starting Google Sign In process...');

      final userCredential = await _firebaseService.signInWithGoogle();

      if (userCredential?.user != null) {
        print('Sign in successful. User ID: ${userCredential?.user?.uid}');
        emit(const AuthSuccess());
      } else {
        print('Sign in failed. UserCredential is null');
        emit(const AuthFailure('فشل تسجيل الدخول. حاول مرة أخرى.'));
      }
    } catch (e) {
      print('Error during sign in: $e');
      emit(AuthFailure('حدث خطأ أثناء تسجيل الدخول: ${e.toString()}'));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _firebaseService.signOut();
      emit(const AuthInitial());
    } catch (e) {
      emit(AuthFailure('حدث خطأ أثناء تسجيل الخروج: ${e.toString()}'));
    }
  }

  void checkAuthState() {
    final user = _firebaseService.currentUser;
    if (user != null) {
      emit(const AuthSuccess());
    } else {
      emit(const AuthInitial());
    }
  }
}
