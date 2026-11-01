import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_guitar/audio/sequence_player.dart';
import 'package:mobile_guitar/main.dart';
import 'package:mobile_guitar/models/sequence_item.dart';
import 'package:mobile_guitar/screens/sequence_editor_screen.dart';

import 'support/fake_chord_audio.dart';

void main() {
  testWidgets('예시 진행과 코드 팔레트를 보여 준다', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileGuitarApp());
    await tester.pumpAndSettle();

    expect(find.text('코드 연주'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('palette-C')), findsOneWidget);
    expect(find.text('2.0초'), findsWidgets);
    expect(find.textContaining('4개'), findsOneWidget);

    final Finder verticalList = find.byWidgetPredicate(
      (Widget widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text('1.5초'),
      300,
      scrollable: verticalList,
    );
    expect(find.text('1.5초'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('2.5초'),
      300,
      scrollable: verticalList,
    );
    expect(find.text('2.5초'), findsOneWidget);
  });

  testWidgets('코드를 추가하고 길이를 바꾼 뒤 뺄 수 있다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SequenceEditorScreen(initialItems: <SequenceItem>[]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('empty-sequence')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('palette-C')));
    await tester.pump();
    expect(find.text('2.0초'), findsOneWidget);

    await tester.tap(find.byTooltip('0.5초 늘리기'));
    await tester.pump();
    expect(find.text('2.5초'), findsOneWidget);

    await tester.tap(find.byTooltip('이 코드 빼기'));
    await tester.pump();
    expect(find.byKey(const Key('empty-sequence')), findsOneWidget);
    expect(find.text('순서가 비어 있습니다'), findsOneWidget);
  });

  testWidgets('재생하면 칸 길이 뒤에 다음 코드로 넘어가고 정지로 멈춘다', (WidgetTester tester) async {
    final FakeChordAudio audio = FakeChordAudio();
    final SequencePlayer player = SequencePlayer(audio: audio);
    addTearDown(player.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: SequenceEditorScreen(
          player: player,
          initialItems: const <SequenceItem>[
            SequenceItem(id: 'a', chordId: 'C', durationMs: 2000),
            SequenceItem(id: 'b', chordId: 'G', durationMs: 2000),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('play-button')));
    await tester.pump();
    expect(find.textContaining('재생 중 1/2 · C'), findsOneWidget);
    expect(audio.prepared, <String>['assets/chords/C.wav']);
    expect(find.byTooltip('이 코드 빼기'), findsWidgets);
    final IconButton delete = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.close).first,
    );
    expect(delete.onPressed, isNull);

    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.textContaining('재생 중 2/2 · G'), findsOneWidget);
    expect(audio.prepared, <String>[
      'assets/chords/C.wav',
      'assets/chords/G.wav',
    ]);

    await tester.tap(find.byKey(const Key('stop-button')));
    await tester.pump();
    expect(find.textContaining('재생 중'), findsNothing);
    expect(player.isPlaying, isFalse);
  });

  testWidgets('좁은 화면에서 넘치지 않는다', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MobileGuitarApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('play-button')), findsOneWidget);
  });
}
