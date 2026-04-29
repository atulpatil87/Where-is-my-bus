import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import 'providers_setup.dart';

// ── Auth state stream ─────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(userRepositoryProvider).authStateChanges;
});

// ── Current user profile ──────────────────────────────────────────────────────
final userProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  final repo = ref.read(userRepositoryProvider);
  final result = await repo.getUserProfile(userId);
  return result.fold(
    (f) => throw Exception((f as dynamic).message ?? f.toString()),
    (u) => u,
  );
});

// ── User stats (for Profile Screen) ──────────────────────────────────────────
final userStatsProvider =
    FutureProvider.autoDispose<UserStats>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const UserStats();
  final useCase = ref.read(getUserStatsUseCaseProvider);
  final result = await useCase.call(user.id);
  return result.fold(
    (f) => const UserStats(),
    (s) => s,
  );
});

// ── Sign in / sign out actions ────────────────────────────────────────────────
final signInProvider =
    StateNotifierProvider<SignInNotifier, AsyncValue<User?>>((ref) {
  return SignInNotifier(ref);
});

class SignInNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref _ref;

  SignInNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signInUseCaseProvider);
    final result = await useCase.withGoogle();
    state = result.fold(
      (f) => AsyncValue.error(Exception(f.message), StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signInAsGuest() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(signInUseCaseProvider);
    final result = await useCase.asGuest();
    state = result.fold(
      (f) => AsyncValue.error(Exception(f.message), StackTrace.current),
      (user) => AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    final repo = _ref.read(userRepositoryProvider);
    await repo.signOut();
    state = const AsyncValue.data(null);
  }
}
