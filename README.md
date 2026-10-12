# pocket_calculator

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Analytics + Crashlytics setup

1. From the project root, install dependencies:
   - `flutter pub get`
2. Install FlutterFire CLI if needed:
   - `dart pub global activate flutterfire_cli`
3. Configure Firebase for this app from the project root:
   - `flutterfire configure`
   - This command generates real `lib/firebase_options.dart` values for your Firebase project.
4. Download `GoogleService-Info.plist` from Firebase Console for the iOS app.
5. Put `GoogleService-Info.plist` into `ios/Runner/GoogleService-Info.plist` and ensure it is included in the Runner target in Xcode.
6. Reinstall iOS pods if needed:
   - `cd ios && pod install && cd ..`
7. Run and verify:
   - `flutter run`

If Firebase is not configured yet, the app still starts, but Analytics and Crashlytics stay disabled until step 3+5 are completed.
