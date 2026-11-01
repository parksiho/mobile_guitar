/// 연주 순서의 한 칸.
///
/// [durationMs]는 소리 파일 길이가 아니라, 다음 코드가 시작하기까지
/// 이 칸이 차지하는 시간입니다. 파일이 더 짧으면 나머지는 쉼이고,
/// 더 길면 이 시간이 끝나는 순간 끊고 다음 코드로 넘어갑니다.
class SequenceItem {
  const SequenceItem({
    required this.id,
    required this.chordId,
    required this.durationMs,
  });

  /// 리스트에서 칸을 구분하는 아이디. 코드 이름과는 다릅니다.
  final String id;

  /// 코드 아이디. `assets/chords/` 파일 이름(확장자 제외)과 같습니다.
  final String chordId;

  final int durationMs;

  static const int minDurationMs = 500;
  static const int maxDurationMs = 8000;
  static const int stepMs = 500;
  static const int defaultDurationMs = 2000;

  Duration get duration => Duration(milliseconds: durationMs);

  SequenceItem withDurationMs(int durationMs) {
    return SequenceItem(
      id: id,
      chordId: chordId,
      durationMs: durationMs.clamp(minDurationMs, maxDurationMs).toInt(),
    );
  }
}

/// 밀리초를 `2.0초`처럼 소수 한 자리로 보여 줍니다.
String formatChordDuration(int durationMs) {
  return '${(durationMs / 1000).toStringAsFixed(1)}초';
}
