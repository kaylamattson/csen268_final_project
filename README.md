# Sensle – organized Flutter UI

This is a drop-in replacement for the `lib/` directory in your **existing** `csen268_final_project` repository. Do not overwrite `android/`, `ios/`, `pubspec.yaml`, or `.git/`.

## Install
1. Commit or back up your current working project first.
2. Replace the project's existing `lib/` folder with this ZIP's `lib/` folder.
3. Run `dart format lib` (optional), `flutter analyze`, `flutter test`, and `flutter run -d emulator-5554`.
4. Inspect the app in the emulator before committing and pushing. The source is reorganized but hasn't been SDK-compiled in this environment.

## Responsibilities
- `main.dart`: app entry point and Material theme
- `theme/`: colors
- `models/`: sensor types and labels
- `screens/`: all full pages, plus results dialog and the tab shell
- `widgets/`: reusable UI building blocks and custom sensor drawings

The displayed sensor values remain **mock values**, not actual hardware readings. App behavior and navigation are intended to stay the same as the original UI source.
