import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/technician_model.dart';
import '../services/auth_service.dart';
<<<<<<< HEAD
=======
import '../services/api_service.dart';
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
import '../services/technician_service.dart';
import '../services/user_service.dart';
import '../services/push_service.dart';

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (_authService.isAuthenticated) {
        final response = await _authService.getMe();
        if (response.success && response.data != null) {
          state = state.copyWith(
            user: response.data,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _authService.login(
      phone: phone,
      password: password,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isAuthenticated: true,
        isLoading: false,
      );
      PushService().init(); // register FCM token
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? 'Login failed',
      );
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await _authService.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      password: password,
      role: role,
    );

    if (response.success && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isAuthenticated: true,
        isLoading: false,
      );
      PushService().init(); // register FCM token
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? 'Registration failed',
      );
      return false;
    }
  }

<<<<<<< HEAD
  Future<bool> loginWithGoogle({String role = 'user'}) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _authService.googleSignIn(role: role);
    if (response.success && response.data != null) {
      state = state.copyWith(
        user: response.data,
        isAuthenticated: true,
        isLoading: false,
      );
      PushService().init();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message ?? 'Google sign-in failed',
      );
      return false;
    }
  }

=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  Future<String?> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
<<<<<<< HEAD
    String? avatar,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  }) async {
    final response = await UserService().updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
<<<<<<< HEAD
      avatar: avatar,
=======
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    );
    if (response.success && response.data != null) {
      state = state.copyWith(user: response.data);
      return null;
    }
    return response.message ?? 'Failed to update profile';
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Simple providers for auth state
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Returns the technician profile if it exists, null if not yet created
final technicianProfileProvider = FutureProvider<TechnicianModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != 'technician') return null;
  final result = await TechnicianService().getMyProfile();
  return result.success ? result.data : null;
});
