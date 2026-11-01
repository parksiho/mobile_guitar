import 'package:flutter/material.dart';

/// 화면 아래의 재생 상태와 재생/정지 버튼.
class PlaybackBar extends StatelessWidget {
  const PlaybackBar({
    super.key,
    required this.status,
    required this.errorMessage,
    required this.canPlay,
    required this.canStop,
    required this.onPlay,
    required this.onStop,
  });

  final String status;
  final String? errorMessage;
  final bool canPlay;
  final bool canStop;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                status,
                key: const Key('playback-status'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 4),
                Text(
                  errorMessage!,
                  key: const Key('playback-error'),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.error),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('play-button'),
                      onPressed: canPlay ? onPlay : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('재생'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('stop-button'),
                      onPressed: canStop ? onStop : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('정지'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
