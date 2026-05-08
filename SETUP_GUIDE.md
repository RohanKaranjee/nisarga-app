# Nisarga App — Complete Setup Guide (A to Z)

This guide walks you through setting up and running the Nisarga Flutter app on a **brand new machine** after cloning the repository.

---

## Prerequisites (Install These First)

### 1. Install Flutter SDK
- Download from: https://docs.flutter.dev/get-started/install
- Extract to a folder like `C:\flutter`
- Add `C:\flutter\bin` to your system **PATH** environment variable.
- Verify installation:
  ```bash
  flutter doctor
  ```

### 2. Install Android Studio
- Download from: https://developer.android.com/studio
- During installation, make sure to check:
  - ✅ Android SDK
  - ✅ Android SDK Command-line Tools
  - ✅ Android SDK Build-Tools
  - ✅ Android Emulator (optional, for testing without a phone)
- After installation, open Android Studio → **SDK Manager** → **SDK Tools** tab → Make sure **Android SDK Command-line Tools** is installed.
- Accept Android licenses:
  ```bash
  flutter doctor --android-licenses
  ```

### 3. Install Git
- Download from: https://git-scm.com/downloads
- Verify:
  ```bash
  git --version
  ```

### 4. Install VS Code (Recommended Editor)
- Download from: https://code.visualstudio.com/
- Install the **Flutter** and **Dart** extensions from the Extensions marketplace.

### 5. Install Node.js (Required for Firebase CLI)
- Download from: https://nodejs.org/ (LTS version recommended)
- Verify:
  ```bash
  node --version
  npm --version
  ```

---

## Step-by-Step Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/RohanKaranjee/nisarga-app.git
cd nisarga-app
```

---

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This reads the `pubspec.yaml` file and downloads all required Dart/Flutter packages.

---

### Step 3: Set Up Firebase CLI

Install the Firebase CLI globally:

```bash
npm install -g firebase-tools
```

Log in to the Firebase account that owns the project:

```bash
firebase login
```
> **Important:** Log in with `akshatahadapad19@gmail.com` (or whatever Google account owns the Firebase project).

---

### Step 4: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Make sure the Dart pub global bin is in your PATH. Typically:
- **Windows:** `C:\Users\<YourUser>\AppData\Local\Pub\Cache\bin`
- **macOS/Linux:** `$HOME/.pub-cache/bin`

---

### Step 5: Configure Firebase for this Machine

Run the FlutterFire configuration command from the project root:

```bash
flutterfire configure --project=nisarga-app-main
```

This will automatically:
- Detect your Flutter app
- Generate/update `lib/firebase_options.dart`
- Generate/update `android/app/google-services.json`

> **Note:** The project ID is `nisarga-app-main`. If it differs, check the Firebase Console for the correct project ID.

---

### Step 6: Add SHA Fingerprints (Required for Phone Auth & Google Sign-In)

Phone OTP and Google Sign-In require your machine's unique SHA fingerprints to be registered in Firebase.

#### Get your debug SHA keys:

```bash
cd android
./gradlew signingReport
```

Look for the output under `Variant: debug`. You need:
- **SHA1** (looks like: `AA:BB:CC:DD:...`)
- **SHA-256** (looks like: `AA:BB:CC:DD:...`)

#### Add them to Firebase:
1. Go to [Firebase Console](https://console.firebase.google.com/) → Your Project → **Project Settings** (gear icon).
2. Scroll down to **Your Apps** → Select the Android app.
3. Click **Add Fingerprint** and paste your **SHA-1**.
4. Click **Add Fingerprint** again and paste your **SHA-256**.
5. Download the updated `google-services.json` and replace the file at `android/app/google-services.json`.

---

### Step 7: Verify Firebase Services are Enabled

In the [Firebase Console](https://console.firebase.google.com/), make sure these are enabled:

1. **Authentication** → Sign-in method tab:
   - ✅ Email/Password → Enabled
   - ✅ Google → Enabled
   - ✅ Phone → Enabled

2. **Cloud Firestore** → Should show a database (if not, click "Create Database" → Start in **Test Mode**).

---

### Step 8: Verify Everything is Ready

```bash
flutter doctor
```

Make sure you see all green checkmarks (✅) for:
- Flutter
- Android toolchain
- Android Studio
- VS Code (if using it)
- Connected device (if a phone/emulator is connected)

---

## Running the App

### Option A: Run in Debug Mode (Recommended for Development)

Connect an Android phone via USB (with USB Debugging enabled) or start an Android Emulator, then:

```bash
flutter run
```

### Option B: Build a Release APK

```bash
flutter build apk
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Option C: Build an App Bundle (For Play Store)

```bash
flutter build appbundle
```

The AAB will be at: `build/app/outputs/bundle/release/app-release.aab`

---

## Troubleshooting

### "No connected devices"
- Make sure USB Debugging is enabled on your phone: **Settings → Developer Options → USB Debugging**
- Or start an emulator from Android Studio → **Device Manager**

### "Firebase App not initialized"
- Make sure you ran `flutterfire configure --project=nisarga-app-main`
- Make sure `android/app/google-services.json` exists and is up-to-date

### "Google Sign-In failed" or "Phone OTP reCAPTCHA keeps appearing"
- Your SHA fingerprints are not registered. Repeat **Step 6** above.
- After adding fingerprints, re-download `google-services.json` and replace the old one.

### "Gradle build failed"
- Try cleaning the build cache:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### "Firestore permission denied"
- Go to Firebase Console → **Firestore Database** → **Rules** tab → Make sure it says:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if true;
      }
    }
  }
  ```
  > ⚠️ This is "test mode" and is fine for development. For production, add proper security rules.

---

## Project Structure (Quick Reference)

```
lib/
├── core/
│   ├── models/          # Data models (CycleData, DailyLog, Reminder)
│   ├── providers/       # State management (AuthProvider, CycleProvider, ReminderProvider)
│   ├── routes/          # App routing (GoRouter)
│   ├── services/        # Backend services (AuthService, FirestoreService)
│   └── theme/           # App colors and styling
├── presentation/
│   ├── screens/         # All UI screens (Home, Search, Profile, Auth, etc.)
│   └── widgets/         # Reusable UI components
├── firebase_options.dart # Auto-generated Firebase config
└── main.dart            # App entry point
```

---

## Quick Commands Cheat Sheet

| Command | What it does |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app in debug mode |
| `flutter build apk` | Build release APK |
| `flutter clean` | Clear build cache |
| `flutter analyze` | Check code for errors |
| `flutter doctor` | Check environment setup |
| `flutterfire configure` | Reconfigure Firebase |
| `firebase login` | Log in to Firebase CLI |

---

**You're all set! 🚀**
