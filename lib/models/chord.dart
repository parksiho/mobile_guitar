/// 팔레트에 나오는 코드 하나.
///
/// [id]는 `assets/chords/` 안 파일 이름에서 확장자를 뺀 값입니다.
/// 예: `Am.mp3` → id `Am`.
class Chord {
  const Chord({required this.id, required this.name, required this.assetPath});

  final String id;
  final String name;

  /// Flutter 자산 경로. 예: `assets/chords/Am.mp3`.
  final String assetPath;
}
