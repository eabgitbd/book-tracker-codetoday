import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AmbientSound {
  rain,
  library,
  fireplace,
  cafe,
}

extension AmbientSoundExtension on AmbientSound {
  String get title {
    switch (this) {
      case AmbientSound.rain:
        return 'Gentle Rain';
      case AmbientSound.library:
        return 'Old Library Atmosphere';
      case AmbientSound.fireplace:
        return 'Cozy Fireplace';
      case AmbientSound.cafe:
        return 'Quiet Parisian Cafe';
    }
  }

  String get icon {
    switch (this) {
      case AmbientSound.rain:
        return '🌧️';
      case AmbientSound.library:
        return '📚';
      case AmbientSound.fireplace:
        return '🔥';
      case AmbientSound.cafe:
        return '☕';
    }
  }
}

class SoundPlayerState {
  final bool isPlaying;
  final AmbientSound currentSound;
  final int timerMinutesRemaining;

  const SoundPlayerState({
    this.isPlaying = false,
    this.currentSound = AmbientSound.rain,
    this.timerMinutesRemaining = 0,
  });

  SoundPlayerState copyWith({
    bool? isPlaying,
    AmbientSound? currentSound,
    int? timerMinutesRemaining,
  }) {
    return SoundPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentSound: currentSound ?? this.currentSound,
      timerMinutesRemaining: timerMinutesRemaining ?? this.timerMinutesRemaining,
    );
  }
}

class SoundPlayerNotifier extends StateNotifier<SoundPlayerState> {
  SoundPlayerNotifier() : super(const SoundPlayerState());

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void selectSound(AmbientSound sound) {
    state = state.copyWith(currentSound: sound, isPlaying: true);
  }

  void setTimer(int minutes) {
    state = state.copyWith(timerMinutesRemaining: minutes);
  }
}

final soundPlayerProvider = StateNotifierProvider<SoundPlayerNotifier, SoundPlayerState>((ref) {
  return SoundPlayerNotifier();
});
