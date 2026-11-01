import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// 코드 소리 하나를 준비하고 재생하는 얇은 경계.
///
/// 테스트에서는 이 인터페이스만 가짜로 바꿉니다.
abstract class ChordAudio {
  Future<void> prepare(String assetPath);

  /// 준비된 소리를 처음부터 재생합니다.
  /// 재생이 끝날 때까지 기다리지 않아도 됩니다.
  Future<void> play();

  Future<void> stop();

  Future<void> dispose();
}

/// [just_audio]로 자산 파일을 재생합니다.
class JustAudioChordAudio implements ChordAudio {
  JustAudioChordAudio({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  bool _sessionReady = false;

  Future<void> _ensureSession() async {
    if (_sessionReady) {
      return;
    }
    try {
      final AudioSession session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {
      // 오디오 포커스를 못 잡아도 파일 재생은 시도합니다.
    }
    _sessionReady = true;
  }

  @override
  Future<void> prepare(String assetPath) async {
    await _ensureSession();
    await _player.setAsset(assetPath);
    await _player.seek(Duration.zero);
  }

  @override
  Future<void> play() {
    return _player.play();
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  Future<void> dispose() {
    return _player.dispose();
  }
}
