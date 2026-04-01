import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'service_providers.dart';

class AuthState {
  final AppUser? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.token, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null && token != null;

  AuthState copyWith({
    AppUser? user,
    String? token,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        token: clearUser ? null : (token ?? this.token),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Try to restore token from SharedPreferences on startup
    _restoreSession();
    return const AuthState();
  }

  Future<void> _restoreSession() async {
    final prefs = SharedPreferencesAsync();
    final token = await prefs.getString('auth_token');
    if (token != null) {
      final api = ref.read(apiServiceProvider);
      api.setAuthToken(token);
      try {
        final user = await api.getMe();
        state = AuthState(user: user, token: token);
      } catch (_) {
        // Token expired or invalid, clear it
        await prefs.remove('auth_token');
        api.setAuthToken(null);
      }
    }
  }

  Future<void> login({
    required String emiratesId,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = ref.read(apiServiceProvider);
      final result =
          await api.login(emiratesId: emiratesId, password: password);
      final token = result['token'] as String;
      final user =
          AppUser.fromJson(result['user'] as Map<String, dynamic>);

      // Save token
      api.setAuthToken(token);
      final prefs = SharedPreferencesAsync();
      await prefs.setString('auth_token', token);

      state = AuthState(user: user, token: token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register({
    required String nameEn,
    required String nameAr,
    required String emiratesId,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.register(
        nameEn: nameEn,
        nameAr: nameAr,
        emiratesId: emiratesId,
        email: email,
        phone: phone,
        password: password,
      );
      final token = result['token'] as String;
      final user =
          AppUser.fromJson(result['user'] as Map<String, dynamic>);

      api.setAuthToken(token);
      final prefs = SharedPreferencesAsync();
      await prefs.setString('auth_token', token);

      state = AuthState(user: user, token: token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final api = ref.read(apiServiceProvider);
    api.setAuthToken(null);
    final prefs = SharedPreferencesAsync();
    await prefs.remove('auth_token');
    state = const AuthState();
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
