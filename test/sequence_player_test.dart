import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_guitar/audio/sequence_player.dart';
import 'package:mobile_guitar/data/chord_catalog.dart';
import 'package:mobile_guitar/models/chord.dart';
import 'package:mobile_guitar/models/sequence_item.dart';

import 'support/fake_chord_audio.dart';

void main() {
  const catalog = ChordCatalog(<Chord>[
    Chord(id: 'C', name: 'C', assetPath: 'assets/chords/C.wav'),
    Chord(id: 'Am', name: 'Am', assetPath: 'assets/chords/Am.wav'),
  ]);

  test('각 칸의 길이만큼 기다린 뒤 다음 코드를 연다', () {
    fakeAsync((FakeAsync async) {
      final FakeChordAudio audio = FakeChordAudio();
      final SequencePlayer player = SequencePlayer(audio: audio);
      var done = false;
      player
          .play(const <SequenceItem>[
            SequenceItem(id: 'a', chordId: 'C', durationMs: 80),
            SequenceItem(id: 'b', chordId: 'Am', durationMs: 120),
          ], catalog)
          .then((_) => done = true);

      async.elapse(Duration.zero);
      expect(player.isPlaying, isTrue);
      expect(player.currentChordId, 'C');
      expect(audio.prepared, <String>['assets/chords/C.wav']);

      async.elapse(const Duration(milliseconds: 79));
      expect(player.currentChordId, 'C');

      async.elapse(const Duration(milliseconds: 1));
      expect(player.currentChordId, 'Am');
      expect(audio.prepared, <String>[
        'assets/chords/C.wav',
        'assets/chords/Am.wav',
      ]);

      async.elapse(const Duration(milliseconds: 120));
      expect(done, isTrue);
      expect(player.isPlaying, isFalse);
      expect(player.currentIndex, isNull);
      // play()가 시작하며 한 번, 각 칸이 끝날 때 한 번씩 멈춥니다.
      expect(audio.stopCount, 3);
      player.dispose();
    });
  });

  test('정지하면 다음 칸으로 넘어가지 않는다', () {
    fakeAsync((FakeAsync async) {
      final FakeChordAudio audio = FakeChordAudio();
      final SequencePlayer player = SequencePlayer(audio: audio);
      player.play(const <SequenceItem>[
        SequenceItem(id: 'a', chordId: 'C', durationMs: 500),
        SequenceItem(id: 'b', chordId: 'Am', durationMs: 500),
      ], catalog);

      async.elapse(Duration.zero);
      expect(audio.prepared, <String>['assets/chords/C.wav']);

      player.stop();
      async.elapse(Duration.zero);
      expect(player.isPlaying, isFalse);

      async.elapse(const Duration(seconds: 2));
      expect(audio.prepared, <String>['assets/chords/C.wav']);
      player.dispose();
    });
  });

  test('파일을 열지 못하면 그 칸은 쉼으로 두고 다음으로 간다', () {
    fakeAsync((FakeAsync async) {
      final FakeChordAudio audio = FakeChordAudio()..failPrepare = true;
      final SequencePlayer player = SequencePlayer(audio: audio);
      var done = false;
      player
          .play(const <SequenceItem>[
            SequenceItem(id: 'a', chordId: 'C', durationMs: 40),
          ], catalog)
          .then((_) => done = true);

      async.elapse(const Duration(milliseconds: 40));
      expect(done, isTrue);
      expect(player.isPlaying, isFalse);
      expect(player.errorMessage, contains('C'));
      expect(audio.playCount, 0);
      player.dispose();
    });
  });
}
