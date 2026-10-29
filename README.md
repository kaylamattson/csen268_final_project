# Sensle – Flutter UI starter (CSEN 268)

A clean, editable Flutter rebuild of the supplied Figma mockups. **No Figma2Flutter dependency or sensor packages.**

## Set up

On your Mac, install Flutter and Android Studio as you did for your Book Club app. Then in Terminal:

```bash
cd /path/to/sensle_flutter
flutter create --platforms=android,ios .
flutter pub get
flutter run -d emulator-5554
```

If you still encounter Java 25 / Gradle 7.6.3, create the platform folders with your installed Flutter SDK as above rather than copying the old `android/` folder from Figma2Flutter. If necessary, use the JDK configured for your working Book Club project.

## What works

- Splash → Home
- Home, Practice, Stats navigation
- Three task screens with Next / Done
- Completion screen and share-results dialog
- Three separate practice screens
- Scalable custom-painted compass, tilt guide and light gauge

## What is simulated

The 15°, 42°, 12%, score, accuracy, time, date and progress feedback are **mock data**, not readings from phone sensors. Complete these separately with sensor permissions and packages after the UI is approved. The challenge currently allows Next/Done without checking a sensor target. Recent-results rows open a sample dialog.

## Source structure

All screens and reusable widgets live in `lib/main.dart` for the simplest first run. You can split them into `screens/`, `widgets/` and `theme/` as the project grows. No extra Dart packages are required.
