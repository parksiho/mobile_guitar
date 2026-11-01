import 'package:flutter/services.dart';

import '../models/chord.dart';

/// 팔레트에 두고 싶은 순서. 여기 없는 파일은 이름순으로 뒤에 붙습니다.
const List<String> preferredChordOrder = <String>[
  'C',
  'D',
  'E',
  'F',
  'G',
  'A',
  'B',
  'Am',
  'Dm',
  'Em',
  'Bm',
  'C7',
  'D7',
  'E7',
  'G7',
  'A7',
];

const String chordAssetPrefix = 'assets/chords/';

/// 같은 코드 이름이 여러 확장자로 있으면 앞에 있는 형식을 고릅니다.
/// 실제 녹음(mp3)을 자리표시자 wav와 같이 두어도 mp3가 재생됩니다.
const List<String> preferredAudioExtensions = <String>[
  'mp3',
  'm4a',
  'ogg',
  'wav',
];

/// 앱에 포함된 코드 소리 목록.
class ChordCatalog {
  const ChordCatalog(this.chords);

  final List<Chord> chords;

  static Future<ChordCatalog> load([AssetBundle? bundle]) async {
    final AssetBundle resolved = bundle ?? rootBundle;
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      resolved,
    );
    return ChordCatalog(chordsFromAssetKeys(manifest.listAssets()));
  }

  Chord? findById(String id) {
    for (final Chord chord in chords) {
      if (chord.id == id) {
        return chord;
      }
    }
    return null;
  }
}

/// 자산 키 목록에서 코드 팔레트를 만듭니다.
///
/// `assets/chords/Am.mp3`처럼 파일 이름(확장자 제외)이 코드 이름이 됩니다.
List<Chord> chordsFromAssetKeys(Iterable<String> keys) {
  final Map<String, int> bestRank = <String, int>{};
  final Map<String, String> bestPath = <String, String>{};

  for (final String key in keys) {
    if (!key.startsWith(chordAssetPrefix)) {
      continue;
    }
    final String filename = key.substring(chordAssetPrefix.length);
    if (filename.isEmpty || filename.contains('/')) {
      continue;
    }
    final int dot = filename.lastIndexOf('.');
    if (dot <= 0 || dot == filename.length - 1) {
      continue;
    }
    final String id = filename.substring(0, dot);
    final String extension = filename.substring(dot + 1).toLowerCase();
    final int rank = preferredAudioExtensions.indexOf(extension);
    if (rank < 0) {
      continue;
    }
    final int? current = bestRank[id];
    if (current == null || rank < current) {
      bestRank[id] = rank;
      bestPath[id] = key;
    }
  }

  final List<String> ids = bestPath.keys.toList()
    ..sort((String a, String b) {
      final int rankA = _orderRank(a);
      final int rankB = _orderRank(b);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

  return <Chord>[
    for (final String id in ids)
      Chord(id: id, name: id, assetPath: bestPath[id]!),
  ];
}

int _orderRank(String id) {
  final int index = preferredChordOrder.indexOf(id);
  if (index >= 0) {
    return index;
  }
  return preferredChordOrder.length;
}
