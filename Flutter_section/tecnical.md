# Fit4 — Technical Overview

This document gives an end-to-end flow of the Flutter mobile app in this repository, explains how the project is structured (including `main.dart`), how it is built/compiled, and a brief description of the components used on each page/file in `lib/`.

## Project Overview

- The workspace contains a Django web backend (folder: `Fit4 Web Django`) and a Flutter mobile client (folder: `Flutter_section`).
- The Flutter app lives under `Flutter_section/lib/` and provides mobile UI pages: `main.dart`, `home.dart`, `login.dart`, `Registration.dart`, `Profile.dart`, `level.dart`, `achievements.dart`, `category.dart`, `exercise.dart`, `UserLog.dart`, and other supporting files.

The Flutter client typically communicates with the backend through HTTP/REST endpoints exposed by the Django server (not shown in detail here). Authentication, user profile, progress and logs are typical responsibilities of the backend.

## Entry point and app flow (`main.dart`)

- `main.dart` is the app entry point. It calls `runApp()` with a root widget (usually `MaterialApp`).
- `MaterialApp` configures theme, routes, and an initial route or `home` widget. Common patterns in apps like this:
  - Show `login` screen if the user is not authenticated.
  - After successful login, `Navigator.pushReplacement` to the `Home` screen.
  - Provide named routes or onGenerateRoute for navigations between pages.

End-to-end typical flow:

1. App launches (`main.dart -> runApp`).
2. If no stored user/session: show `login.dart`.
3. Successful login navigates to `home.dart` (main hub with bottom navigation).
4. From `Home` user can reach `level.dart`, `Profile.dart`, `achievements.dart`, `category.dart`, `exercise.dart`, and `UserLog.dart`.
5. Logout replaces the route stack and returns to `login.dart`.

## Page-by-page summary and main components

- `home.dart` (provided):
  - Stateful widget with `_selectedIndex` and a `_pages` list.
  - Implements a custom bottom navigation built from `Material`, `InkWell`, and `AnimatedContainer` instead of using `BottomNavigationBar` directly. Three tabs: Level, Profile, Logout.
  - Logout triggers `_showLogoutConfirmationDialog()` which uses `AlertDialog` and on confirm uses `Navigator.pushReplacement` to go to the `login` screen.
  - Uses theme information (`Theme.of(context).colorScheme`) and adapts to light/dark by reading `brightness`.

- `login.dart`:
  - Typically contains a `Form` with `TextFormField` widgets for username/email and password, and `ElevatedButton`/`FilledButton` for submit.
  - Validates inputs, calls authentication API (HTTP POST) to the backend, saves token/session (e.g., `shared_preferences`), then navigates to `Home`.

- `Registration.dart`:
  - Registration form similar to `login.dart` with validation fields, and a call to backend registration endpoint.
  - On success, usually navigates to login or directly logs in and navigates to `Home`.

- `Profile.dart`:
  - Displays user information (display name, email, avatar), and possible edit controls.
  - Uses widgets like `CircleAvatar`, `ListTile`, and `Card` to present info.
  - Might include calls to backend to fetch or update profile data.

- `level.dart`:
  - Represents user fitness level UI. Likely displays a progress indicator or cards for levels.
  - May list exercises or categories (uses `ListView`, `GridView`, `Card`, `ElevatedButton`).

- `achievements.dart`:
  - Shows user badges or achievements. Common widgets: `GridView`, `Wrap`, `Card`, and images/icons representing badges.

- `category.dart`:
  - Lists exercise categories (e.g., Push, Pull, Leg). Each category item navigates to `exercise.dart` with parameters.
  - Uses `ListView`, tappable `InkWell`/`GestureDetector` and image assets (gifs for workout previews).

- `exercise.dart`:
  - Displays details for a selected exercise: instruction text, animated gif (from assets), repetitions, and start/complete controls.
  - Likely uses `Image.asset` or `Image.network`, `Text`, and `ElevatedButton`.

- `UserLog.dart`:
  - Shows history of completed workouts. Typical widgets: `ListView` or `PaginatedDataTable`, with date/time and summary metrics.

Notes about components: widgets in pages above are usually organized as `StatelessWidget` for static content or `StatefulWidget` where UI updates are required. The app uses Flutter's `Navigator` stack for transitions. The `home.dart` file shows a custom animated bottom navigation bar using `AnimatedContainer`, `Icon`, and `Text` for subtle transitions.

## Assets and pubspec

- Images/gifs and other static assets are kept under `Flutter_section/assets/` and referenced in `pubspec.yaml` under `flutter/assets:`. This ensures assets are bundled with the app.

## How the project is compiled and run

Development:

- To run on an Android emulator or connected device:
  - `flutter pub get`
  - `flutter run` (or from an IDE: Run/Debug)

Build (release):

- Android APK/AAB:
  - `flutter build apk --release` or `flutter build appbundle --release`
  - Uses Gradle toolchain found under `android/` folder; code is AOT-compiled to native, packaged with the Flutter engine.
- iOS:
  - `flutter build ios --release` (requires macOS and Xcode). Code-signing and provisioning required.
- Web:
  - `flutter build web` produces static web assets in `build/web/`.

Compilation notes:

- In debug mode, Flutter uses JIT to allow hot reload/hot restart for fast iteration.
- In release mode, Dart code is AOT compiled into native machine code and linked with the Flutter engine.
- Platform-specific configuration (Android: Gradle, `AndroidManifest.xml`; iOS: Xcode project) must be correct for distribution.

## Integration with Django backend

- The repo includes a Django app (`Fit4 Web Django`) with `manage.py` and server-side templates under `static/` and `templates/`. The mobile app likely communicates with Django via REST endpoints (e.g., `/api/login`, `/api/profile`) — check server-side `views.py` and `urls.py` for exact endpoints.
- Authentication flow: mobile sends credentials to backend; on success backend returns token/session which the mobile app stores (commonly `shared_preferences`) and attaches to subsequent requests.

## Debugging & Tips

- Use `flutter doctor` to validate development environment.
- Use `flutter analyze` to catch static analysis issues.
- For network debugging, use proxy tools or inspect responses from the Django server. Ensure CORS is allowed for web if using browser builds.

## Where to look next

- Inspect `main.dart` to confirm the app entry and route configuration.
- Inspect each page under `lib/` to confirm actual UI elements and network calls.
- Inspect `pubspec.yaml` for dependencies and asset declarations.

If you want, I can:

- Open and summarize `main.dart` and other specific files verbatim.
- Add a diagram of navigation flow.
- Generate a short README with run commands for Android/iOS.

---

Generated summary for quick orientation — tell me which file you want a deeper walkthrough of next.
