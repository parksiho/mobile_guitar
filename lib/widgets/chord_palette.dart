import 'package:flutter/material.dart';

import '../models/chord.dart';

/// 미리 넣어 둔 코드 목록. 누르면 연주 순서 끝에 추가됩니다.
class ChordPalette extends StatelessWidget {
  const ChordPalette({
    super.key,
    required this.chords,
    required this.enabled,
    required this.onSelected,
  });

  final List<Chord> chords;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (chords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('assets/chords/에 wav 또는 mp3 파일을 넣어 주세요.'),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView.separated(
        key: const Key('chord-palette'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chords.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final Chord chord = chords[index];
          return Align(
            alignment: Alignment.center,
            child: ActionChip(
              key: ValueKey<String>('palette-${chord.id}'),
              label: Text(chord.name),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: enabled ? () => onSelected(chord.id) : null,
            ),
          );
        },
      ),
    );
  }
}
