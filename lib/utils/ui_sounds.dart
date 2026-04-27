import 'package:audioplayers/audioplayers.dart';

/// Short UI feedback sounds (swipe, done).
/// Creates a fresh AudioPlayer per play to avoid stale-state failures.
class UiSounds {
  UiSounds._();

  static Future<void> playSwipe() async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sounds/swipe.mp3'));
      await player.onPlayerComplete.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => AudioEvent(eventType: AudioEventType.complete),
      );
    } catch (_) {
    } finally {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  static Future<void> playDone() async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource('sounds/done.mp3'));
      await player.onPlayerComplete.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => AudioEvent(eventType: AudioEventType.complete),
      );
    } catch (_) {
    } finally {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }
}
