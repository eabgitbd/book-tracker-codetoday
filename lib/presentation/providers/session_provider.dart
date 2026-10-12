import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/session_repository.dart';
import '../../domain/models/reading_session.dart';
import '../../domain/services/streak_calculator.dart';
import 'settings_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final storage = ref.watch(localStorageSourceProvider);
  return SessionRepository(storage);
});

class SessionsNotifier extends StateNotifier<List<ReadingSession>> {
  final SessionRepository _repo;

  SessionsNotifier(this._repo) : super([]) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    final list = await _repo.getAllSessions();
    state = list;
  }

  Future<void> logSession(ReadingSession session) async {
    await _repo.addSession(session);
    await loadSessions();
  }
}

final sessionsProvider = StateNotifierProvider<SessionsNotifier, List<ReadingSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionsNotifier(repo);
});

final streakProvider = Provider<StreakResult>((ref) {
  final sessions = ref.watch(sessionsProvider);
  return StreakCalculator.calculateStreak(sessions);
});
