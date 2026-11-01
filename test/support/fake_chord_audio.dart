import 'package:mobile_guitar/audio/chord_audio.dart';

/// 테스트용 재생기. 파일을 열지 않고 호출만 기록합니다.
class FakeChordAudio implements ChordAudio {
  final List<String> prepared = <String>[];
  int playCount = 0;
  int stopCount = 0;
  bool failPrepare = false;

  @override
  Future<void> prepare(String assetPath) async {
    prepared.add(assetPath);
    if (failPrepare) {
      throw StateError('missing $assetPath');
    }
  }

  @override
  Future<void> play() async {
    playCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  Future<void> dispose() async {}
}
