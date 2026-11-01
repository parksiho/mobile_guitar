import 'package:flutter/foundation.dart';

import '../models/sequence_item.dart';

/// 연주 순서를 추가·삭제·재배치하고 칸 길이를 바꿉니다.
class SequenceEditorController extends ChangeNotifier {
  SequenceEditorController({List<SequenceItem>? initialItems}) {
    _items.addAll(initialItems ?? demoItems);
  }

  /// 처음 실행하면 길이가 서로 다른 예시 진행이 들어 있습니다.
  static const List<SequenceItem> demoItems = <SequenceItem>[
    SequenceItem(id: 'demo-c', chordId: 'C', durationMs: 2000),
    SequenceItem(id: 'demo-g', chordId: 'G', durationMs: 2000),
    SequenceItem(id: 'demo-am', chordId: 'Am', durationMs: 1500),
    SequenceItem(id: 'demo-f', chordId: 'F', durationMs: 2500),
  ];

  final List<SequenceItem> _items = <SequenceItem>[];
  int _nextId = 0;

  List<SequenceItem> get items => List<SequenceItem>.unmodifiable(_items);

  int get totalDurationMs {
    var total = 0;
    for (final SequenceItem item in _items) {
      total += item.durationMs;
    }
    return total;
  }

  void addChord(String chordId) {
    _items.add(
      SequenceItem(
        id: 'step-$_nextId',
        chordId: chordId,
        durationMs: SequenceItem.defaultDurationMs,
      ),
    );
    _nextId += 1;
    notifyListeners();
  }

  void remove(String id) {
    final int index = _items.indexWhere((SequenceItem item) => item.id == id);
    if (index < 0) {
      return;
    }
    _items.removeAt(index);
    notifyListeners();
  }

  /// 놓는 위치의 최종 인덱스입니다.
  ///
  /// ReorderableListView.onReorderItem이 이미 빼낸 자리를 보정해 주므로
  /// 여기서는 newIndex를 다시 줄이지 않습니다.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _items.length ||
        newIndex < 0 ||
        newIndex >= _items.length ||
        oldIndex == newIndex) {
      return;
    }
    final SequenceItem item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    notifyListeners();
  }

  void nudgeDuration(String id, int deltaMs) {
    final int index = _items.indexWhere((SequenceItem item) => item.id == id);
    if (index < 0) {
      return;
    }
    final SequenceItem current = _items[index];
    final SequenceItem next = current.withDurationMs(
      current.durationMs + deltaMs,
    );
    if (next.durationMs == current.durationMs) {
      return;
    }
    _items[index] = next;
    notifyListeners();
  }
}
