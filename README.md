# 코드 연주

기타 코드를 원하는 순서로 늘어놓고, 각 코드가 울릴 시간을 정한 뒤 이어서 듣는 Android 앱입니다. 코드 진행을 소리로 확인하는 용도의 MVP 뼈대입니다.

처음 켜면 `C → G → Am → F` 예시가 들어 있고, 길이는 2.0초, 2.0초, 1.5초, 2.5초로 서로 다릅니다. 재생을 누르면 그 순서와 길이대로 소리가 이어집니다.

## 실행

Flutter 안정 채널이 필요합니다. 이 프로젝트는 Flutter 3.47.9 / Dart 3.13.7에서 만들었습니다. Android `minSdk`는 Flutter가 정한 값(현재 24, Android 7.0)을 그대로 씁니다.

```bash
flutter pub get
flutter run
```

Android 기기나 에뮬레이터를 연결한 상태에서 실행합니다. 패키지 이름은 `com.chordplay.mobile_guitar`입니다.

```bash
flutter analyze
flutter test
```

## 소리 파일 넣기

소리 파일은 `assets/chords/`에 둡니다. **파일 이름에서 확장자를 뺀 부분이 코드 이름**입니다.

| 파일 | 앱에 보이는 이름 |
| --- | --- |
| `C.mp3` | C |
| `Am.wav` | Am |
| `G7.m4a` | G7 |
| `F#m.ogg` | F#m |

지원하는 확장자는 `mp3`, `m4a`, `ogg`, `wav`입니다. 대소문자를 구분하므로 `Am.mp3`처럼 적습니다. `am.mp3`는 다른 코드로 취급됩니다.

같은 이름의 파일이 여러 확장자로 있으면 **mp3 → m4a → ogg → wav** 순서로 하나를 고릅니다. 저장소에 들어 있는 `C.wav`를 지우지 않고 `C.mp3`를 옆에 두어도 mp3가 재생됩니다.

파일을 추가하거나 바꾼 뒤에는 앱을 완전히 다시 실행해야 합니다. 핫 리로드로는 새 자산이 들어가지 않습니다. `pubspec.yaml`에는 폴더 전체가 등록되어 있어서, 이 폴더에 넣은 파일은 따로 목록에 적지 않아도 됩니다.

팔레트 순서를 바꾸고 싶으면 `lib/data/chord_catalog.dart`의 `preferredChordOrder`를 고칩니다. 이 목록에 없는 파일도 앱에 나타나며, 이름순으로 뒤에 붙습니다.

## 자리표시자 합성음

저장소의 wav는 기타 녹음이 아닙니다. 코드마다 약 0.6초짜리 합성 화음이라, 앱을 받은 뒤 바로 재생해 볼 수 있게 넣은 것입니다. 다시 만들려면 다음을 실행합니다.

```bash
python3 tool/generate_placeholder_chords.py
```

실제 기타 샘플로 바꿀 때는 같은 규칙의 파일 이름으로 넣으면 됩니다. 예: `assets/chords/C.mp3`, `assets/chords/Am.mp3`.

## 길이는 이렇게 동작합니다

각 칸의 길이는 “이 코드 소리가 끝나기까지의 파일 길이”가 아니라 **다음 코드가 나오기까지 이 칸이 차지하는 시간**입니다.

- 칸이 2초이고 파일이 0.6초면, 0.6초 재생 후 남은 1.4초는 쉽니다.
- 칸이 1초이고 파일이 3초면, 1초에서 끊고 다음 코드를 시작합니다.
- 길이는 0.5초 단위로 0.5초에서 8.0초까지 바꿀 수 있습니다.
- 순서는 왼쪽 손잡이를 끌어 바꿉니다. 재생 중에는 순서를 잠급니다.

다음 파일을 읽는 동안 아주 짧은 틈이 생길 수 있습니다.

## 폴더

```text
lib/
  main.dart                 앱 시작
  models/                   코드, 순서의 한 칸
  data/chord_catalog.dart   assets/chords/에서 코드 목록을 읽음
  audio/                    재생
  state/                    순서 편집
  screens/                  화면
  widgets/
assets/chords/              코드 소리 파일
tool/generate_placeholder_chords.py
```
