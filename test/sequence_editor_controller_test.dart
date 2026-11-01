import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_guitar/models/sequence_item.dart';
import 'package:mobile_guitar/state/sequence_editor_controller.dart';

void main() {
  test('길이를 소수 한 자리 초로 보여 준다', () {
    expect(formatChordDuration(2000), '2.0초');
    expect(formatChordDuration(1500), '1.5초');
  });

  test('추가, 삭제, 길이 조절, 순서 변경', () {
    final controller = SequenceEditorController(
      initialItems: const <SequenceItem>[],
    );
    controller.addChord('C');
    controller.addChord('Am');
    expect(controller.items.map((item) => item.chordId), <String>['C', 'Am']);
    expect(controller.items.first.durationMs, SequenceItem.defaultDurationMs);

    controller.nudgeDuration(controller.items.first.id, -500);
    expect(controller.items.first.durationMs, 1500);
    controller.nudgeDuration(controller.items.first.id, -5000);
    expect(controller.items.first.durationMs, SequenceItem.minDurationMs);
    controller.nudgeDuration(controller.items.first.id, 100000);
    expect(controller.items.first.durationMs, SequenceItem.maxDurationMs);

    controller.reorder(0, 1);
    expect(controller.items.map((item) => item.chordId), <String>['Am', 'C']);

    final String removedId = controller.items.first.id;
    controller.remove(removedId);
    controller.remove('없는-아이디');
    expect(controller.items.map((item) => item.chordId), <String>['C']);
    expect(controller.totalDurationMs, controller.items.single.durationMs);
  });

  test('예시 진행은 칸 길이가 서로 다르다', () {
    final durations = SequenceEditorController.demoItems
        .map((item) => item.durationMs)
        .toSet();
    expect(durations.length, greaterThan(1));
  });
}
