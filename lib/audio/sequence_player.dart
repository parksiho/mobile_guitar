import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/chord_catalog.dart';
import '../models/sequence_item.dart';
import 'chord_audio.dart';

/// 코드 순서를 칸의 길이대로 이어 재생합니다.
///
/// 소리 파일을 늘리거나 이어 붙이지 않습니다. 각 칸이 시작될 때
/// 파일을 처음부터 틀고, [SequenceItem.duration]이 끝나면 멈추고
/// 다음 칸으로 넘어갑니다. 파일이 칸보다 짧으면 남는 시간은 쉼입니다.
class SequencePlayer extends ChangeNotifier {
  SequencePlayer({ChordAudio? audio}) : _audio = audio ?? JustAudioChordAudio();

  final ChordAudio _audio;

  int _runId = 0;
  bool _disposed = false;
  bool _playing = false;
  int? _currentIndex;
  String? _currentChordId;
  int? _queueLength;
  String? _errorMessage;
  Timer? _timer;
  Completer<void>? _cancel;

  bool get isPlaying => _playing;
  int? get currentIndex => _currentIndex;
  String? get currentChordId => _currentChordId;
  int? get queueLength => _queueLength;
  String? get errorMessage => _errorMessage;

  Future<void> play(List<SequenceItem> items, ChordCatalog catalog) async {
    await stop();
    if (_disposed || items.isEmpty) {
      return;
    }

    final int runId = ++_runId;
    final List<SequenceItem> queue = List<SequenceItem>.unmodifiable(items);
    _playing = true;
    _currentIndex = null;
    _currentChordId = null;
    _queueLength = queue.length;
    _errorMessage = null;
    _notify();

    try {
      for (var index = 0; index < queue.length; index++) {
        if (runId != _runId || _disposed) {
          return;
        }
        final SequenceItem item = queue[index];
        _playing = true;
        _currentIndex = index;
        _currentChordId = item.chordId;
        _queueLength = queue.length;
        _notify();

        final chord = catalog.findById(item.chordId);
        if (chord == null) {
          _errorMessage =
              '${item.chordId} 코드의 소리 파일이 없습니다. assets/chords/를 확인해 주세요.';
          _notify();
        } else {
          try {
            await _audio.prepare(chord.assetPath);
            if (runId != _runId || _disposed) {
              return;
            }
            _errorMessage = null;
            _notify();
            unawaited(
              _audio.play().then<void>(
                (_) {},
                onError: (Object _, StackTrace _) {},
              ),
            );
          } catch (_) {
            if (runId != _runId || _disposed) {
              return;
            }
            _errorMessage =
                '${chord.name} 소리를 열 수 없습니다. assets/chords/ 파일을 확인해 주세요.';
            _notify();
          }
        }

        final int slotMs = item.durationMs < 0 ? 0 : item.durationMs;
        await _wait(Duration(milliseconds: slotMs));
        if (runId != _runId || _disposed) {
          return;
        }
        await _audio.stop();
      }
    } finally {
      if (runId == _runId && !_disposed) {
        _playing = false;
        _currentIndex = null;
        _currentChordId = null;
        _queueLength = null;
        _notify();
      }
    }
  }

  Future<void> stop() async {
    _runId++;
    _cancelWait();
    _playing = false;
    _currentIndex = null;
    _currentChordId = null;
    _queueLength = null;
    _notify();
    if (!_disposed) {
      await _audio.stop();
    }
  }

  Future<void> _wait(Duration duration) {
    _cancelWait();
    final Completer<void> cancel = Completer<void>();
    _cancel = cancel;
    _timer = Timer(duration, () {
      if (!cancel.isCompleted) {
        cancel.complete();
      }
    });
    return cancel.future;
  }

  void _cancelWait() {
    _timer?.cancel();
    _timer = null;
    final Completer<void>? cancel = _cancel;
    _cancel = null;
    if (cancel != null && !cancel.isCompleted) {
      cancel.complete();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _runId++;
    _cancelWait();
    unawaited(_audio.dispose());
    super.dispose();
  }
}
