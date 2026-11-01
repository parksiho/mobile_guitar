import 'package:flutter/material.dart';

import '../models/sequence_item.dart';

/// 연주 순서의 한 줄. 길이 조절, 삭제, 끌어서 순서 변경을 담습니다.
class SequenceTile extends StatelessWidget {
  const SequenceTile({
    super.key,
    required this.index,
    required this.item,
    required this.chordName,
    required this.highlighted,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final int index;
  final SequenceItem item;
  final String chordName;
  final bool highlighted;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool canDecrease = item.durationMs > SequenceItem.minDurationMs;
    final bool canIncrease = item.durationMs < SequenceItem.maxDurationMs;

    Widget handle = Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(
        Icons.drag_handle,
        color: enabled ? scheme.onSurfaceVariant : scheme.outlineVariant,
      ),
    );
    if (enabled) {
      handle = ReorderableDragStartListener(index: index, child: handle);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: highlighted
          ? scheme.secondaryContainer
          : scheme.surfaceContainerLow,
      elevation: highlighted ? 1 : 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Column(
          children: [
            Row(
              children: [
                handle,
                SizedBox(
                  width: 24,
                  child: Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    chordName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (highlighted) Icon(Icons.graphic_eq, color: scheme.primary),
                IconButton(
                  tooltip: '이 코드 빼기',
                  onPressed: enabled ? onRemove : null,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 12),
                Text('길이', style: Theme.of(context).textTheme.bodyMedium),
                IconButton(
                  tooltip: '0.5초 줄이기',
                  onPressed: enabled && canDecrease ? onDecrease : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  formatChordDuration(item.durationMs),
                  key: ValueKey<String>('duration-${item.id}'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  tooltip: '0.5초 늘리기',
                  onPressed: enabled && canIncrease ? onIncrease : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
