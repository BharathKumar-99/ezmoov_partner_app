import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._privateConstructor();
  static final AudioService instance = AudioService._privateConstructor();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  /// Play incoming ride request alert sound
  Future<void> playRideRequestAlert() async {
    if (_isPlaying) return;
    try {
      _isPlaying = true;
      // Set source to a public alert sound or asset
      await _audioPlayer.setSource(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
      );
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
      debugPrint('🔔 Incoming Ride Audio Alert ringing...');
    } catch (e) {
      _isPlaying = false;
      debugPrint('Notice playing alert audio: $e');
    }
  }

  /// Stop playing alert sound
  Future<void> stopAlert() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        _isPlaying = false;
        debugPrint('🔕 Audio Alert stopped.');
      }
    } catch (e) {
      _isPlaying = false;
      debugPrint('Notice stopping alert audio: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
