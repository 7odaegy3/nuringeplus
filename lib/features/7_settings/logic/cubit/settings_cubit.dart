import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final _prefs = SharedPreferences.getInstance();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  SettingsCubit() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> toggleDarkMode() async {
    final prefs = await _prefs;
    final newValue = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newValue);
    emit(state.copyWith(isDarkMode: newValue));
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      // Handle any errors during logout
      print('Error during logout: $e');
    }
  }
}
