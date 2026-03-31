import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_ai/models/user.dart';
import 'package:campus_ai/providers/chat_provider.dart';
import 'package:campus_ai/services/storage_service.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;
  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) =>
      AuthState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _ref.read(apiServiceProvider).login(email, password);
      await StorageService.setTokens(res.accessToken, res.refreshToken);
      await StorageService.setUserName(res.user.name);
      state = AuthState(user: res.user);
    } on Exception catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _ref.read(apiServiceProvider).register(name, email, password);
      await StorageService.setTokens(res.accessToken, res.refreshToken);
      await StorageService.setUserName(res.user.name);
      state = AuthState(user: res.user);
    } on Exception catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    await StorageService.clearTokens();
    state = const AuthState();
  }
}
