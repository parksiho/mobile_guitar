import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_guitar/data/chord_catalog.dart';

void main() {
  test('같은 이름이면 mp3를 wav보다 먼저 고른다', () {
    final chords = chordsFromAssetKeys(const <String>[
      'assets/chords/C.wav',
      'assets/chords/C.mp3',
      'assets/chords/Am.wav',
      'assets/chords/Am.m4a',
      'assets/chords/F#m.ogg',
      'assets/chords/notes.txt',
      'assets/other/C.mp3',
    ]);

    expect(
      chords
          .map((chord) => '${chord.id}:${chord.assetPath}')
          .toList(growable: false),
      <String>[
        'C:assets/chords/C.mp3',
        'Am:assets/chords/Am.m4a',
        'F#m:assets/chords/F#m.ogg',
      ],
    );
  });

  test('들어 있는 자리표시자 코드를 자산에서 찾는다', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final catalog = await ChordCatalog.load();
    expect(
      catalog.chords.map((chord) => chord.id).toList(growable: false),
      preferredChordOrder,
    );
    expect(catalog.findById('Am')?.assetPath, 'assets/chords/Am.wav');

    final ByteData data = await rootBundle.load('assets/chords/C.wav');
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
    expect(bytes.length, greaterThan(1000));
  });
}
