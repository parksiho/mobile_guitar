import 'package:flutter/material.dart';

import '../audio/sequence_player.dart';
import '../data/chord_catalog.dart';
import '../models/sequence_item.dart';
import '../state/sequence_editor_controller.dart';
import '../widgets/chord_palette.dart';
import '../widgets/playback_bar.dart';
import '../widgets/sequence_tile.dart';

/// 코드 순서를 만들고 재생하는 화면.
class SequenceEditorScreen extends StatefulWidget {
  const SequenceEditorScreen({
    super.key,
    this.player,
    this.catalogLoader,
    this.initialItems,
  });

  /// 테스트를 위해 재생기를 바꿀 수 있습니다. 비우면 just_audio로 재생합니다.
  final SequencePlayer? player;

  final Future<ChordCatalog> Function()? catalogLoader;

  /// null이면 예시 진행(C–G–Am–F)으로 시작합니다.
  final List<SequenceItem>? initialItems;

  @override
  State<SequenceEditorScreen> createState() => _SequenceEditorScreenState();
}

class _SequenceEditorScreenState extends State<SequenceEditorScreen> {
  late final SequenceEditorController _editor;
  late final SequencePlayer _player;
  late final bool _ownsPlayer;
  late final Future<ChordCatalog> _catalogFuture;
  late final Listenable _listenable;

  @override
  void initState() {
    super.initState();
    _editor = SequenceEditorController(initialItems: widget.initialItems);
    _ownsPlayer = widget.player == null;
    _player = widget.player ?? SequencePlayer();
    _catalogFuture = (widget.catalogLoader ?? ChordCatalog.load)();
    _listenable = Listenable.merge(<Listenable>[_editor, _player]);
  }

  @override
  void dispose() {
    _editor.dispose();
    if (_ownsPlayer) {
      _player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChordCatalog>(
      future: _catalogFuture,
      builder: (BuildContext context, AsyncSnapshot<ChordCatalog> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('코드 연주')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '코드 목록을 읽지 못했습니다.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return _LoadedEditor(
          catalog: snapshot.data!,
          editor: _editor,
          player: _player,
          listenable: _listenable,
        );
      },
    );
  }
}

class _LoadedEditor extends StatelessWidget {
  const _LoadedEditor({
    required this.catalog,
    required this.editor,
    required this.player,
    required this.listenable,
  });

  final ChordCatalog catalog;
  final SequenceEditorController editor;
  final SequencePlayer player;
  final Listenable listenable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('코드 연주')),
      body: ListenableBuilder(
        listenable: listenable,
        builder: (BuildContext context, Widget? child) {
          final bool playing = player.isPlaying;
          final String? hint = _hint(playing);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  '코드를 누르는 순서대로 소리가 이어집니다. '
                  '각 칸의 길이가 끝나면 다음 코드가 시작됩니다.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  '기본 소리는 짧은 합성음입니다. assets/chords/에 C.mp3, Am.mp3처럼 '
                  '넣으면 그 파일로 바뀝니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('코드 추가', style: theme.textTheme.titleSmall),
              ),
              ChordPalette(
                chords: catalog.chords,
                enabled: !playing,
                onSelected: editor.addChord,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text('연주 순서', style: theme.textTheme.titleSmall),
              ),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Expanded(child: _sequenceList(context, playing)),
              PlaybackBar(
                status: _status(playing),
                errorMessage: player.errorMessage,
                canPlay: !playing && editor.items.isNotEmpty,
                canStop: playing,
                onPlay: () {
                  player.play(editor.items, catalog);
                },
                onStop: () {
                  player.stop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String? _hint(bool playing) {
    if (playing) {
      return '재생 중에는 순서를 바꿀 수 없습니다.';
    }
    if (editor.items.length >= 2) {
      return '손잡이를 끌어 순서를 바꿀 수 있습니다. 길이는 0.5초 단위입니다.';
    }
    return null;
  }

  String _status(bool playing) {
    if (playing) {
      final int? index = player.currentIndex;
      final int? total = player.queueLength;
      if (index == null || total == null) {
        return '재생 준비 중';
      }
      final String? id = player.currentChordId;
      final String name = id == null ? '' : (catalog.findById(id)?.name ?? id);
      return '재생 중 ${index + 1}/$total · $name';
    }
    if (editor.items.isEmpty) {
      return '순서가 비어 있습니다';
    }
    return '${editor.items.length}개 · ${formatChordDuration(editor.totalDurationMs)}';
  }

  Widget _sequenceList(BuildContext context, bool playing) {
    if (editor.items.isEmpty) {
      return Center(
        key: const Key('empty-sequence'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text('위에서 코드를 고르면 이곳에 쌓입니다.'),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: editor.items.length,
      onReorderItem: (int oldIndex, int newIndex) {
        if (playing) {
          return;
        }
        editor.reorder(oldIndex, newIndex);
      },
      itemBuilder: (BuildContext context, int index) {
        final SequenceItem item = editor.items[index];
        final String name =
            catalog.findById(item.chordId)?.name ?? item.chordId;
        return SequenceTile(
          key: ValueKey<String>(item.id),
          index: index,
          item: item,
          chordName: name,
          highlighted: playing && player.currentIndex == index,
          enabled: !playing,
          onDecrease: () => editor.nudgeDuration(item.id, -SequenceItem.stepMs),
          onIncrease: () => editor.nudgeDuration(item.id, SequenceItem.stepMs),
          onRemove: () => editor.remove(item.id),
        );
      },
    );
  }
}
