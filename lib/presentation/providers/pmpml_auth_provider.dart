import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pmpml/pmpml_auth_model.dart';
import 'pmpml_providers_setup.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum PmpmlAuthStep { idle, sendingOtp, otpSent, verifying, authenticated, error }

class PmpmlAuthState {
  final PmpmlAuthStep step;
  final String? mobile;
  final String? errorMessage;
  final PmpmlAuthModel? authModel;

  const PmpmlAuthState({
    this.step = PmpmlAuthStep.idle,
    this.mobile,
    this.errorMessage,
    this.authModel,
  });

  bool get isAuthenticated => step == PmpmlAuthStep.authenticated;
  bool get isLoading =>
      step == PmpmlAuthStep.sendingOtp || step == PmpmlAuthStep.verifying;

  PmpmlAuthState copyWith({
    PmpmlAuthStep? step,
    String? mobile,
    String? errorMessage,
    PmpmlAuthModel? authModel,
  }) =>
      PmpmlAuthState(
        step: step ?? this.step,
        mobile: mobile ?? this.mobile,
        errorMessage: errorMessage,
        authModel: authModel ?? this.authModel,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PmpmlAuthNotifier extends StateNotifier<PmpmlAuthState> {
  final Ref _ref;

  PmpmlAuthNotifier(this._ref) : super(const PmpmlAuthState()) {
    _checkStoredToken();
  }

  void _checkStoredToken() {
    final repo = _ref.read(pmpmlRepositoryProvider);
    if (!repo.isAuthenticated) return;

    // Optimistically treat the stored session as authenticated…
    state = PmpmlAuthState(
      step: PmpmlAuthStep.authenticated,
      mobile: repo.storedMobile,
    );

    // …but if the access token has expired, silently mint a fresh one from
    // the refresh token (no OTP). Only drop to logged-out if that fails.
    if (repo.isTokenExpired) {
      unawaited(_refreshExpiredSession());
    }
  }

  Future<void> _refreshExpiredSession() async {
    final repo = _ref.read(pmpmlRepositoryProvider);
    final ok = await repo.refreshSession();
    if (!ok) {
      await repo.logout();
      state = const PmpmlAuthState();
    }
  }

  Future<void> sendOtp(String mobile) async {
    state = state.copyWith(step: PmpmlAuthStep.sendingOtp, mobile: mobile);
    final repo = _ref.read(pmpmlRepositoryProvider);
    final result = await repo.sendOtp(mobile);
    result.fold(
      (failure) => state = state.copyWith(
        step: PmpmlAuthStep.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        step: PmpmlAuthStep.otpSent,
        mobile: mobile,
      ),
    );
  }

  Future<void> verifyOtp(String otp) async {
    if (state.mobile == null) return;
    state = state.copyWith(step: PmpmlAuthStep.verifying);
    final repo = _ref.read(pmpmlRepositoryProvider);
    final result = await repo.verifyOtp(state.mobile!, otp);
    result.fold(
      (failure) => state = state.copyWith(
        step: PmpmlAuthStep.error,
        errorMessage: failure.message,
      ),
      (auth) => state = PmpmlAuthState(
        step: PmpmlAuthStep.authenticated,
        mobile: state.mobile,
        authModel: auth,
      ),
    );
  }

  void resetToIdle() {
    state = const PmpmlAuthState();
  }

  Future<void> logout() async {
    final repo = _ref.read(pmpmlRepositoryProvider);
    await repo.logout();
    state = const PmpmlAuthState();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final pmpmlAuthProvider =
    StateNotifierProvider<PmpmlAuthNotifier, PmpmlAuthState>(
  (ref) => PmpmlAuthNotifier(ref),
);
