# 🌿 Nisarga — Menstrual Health & Cycle Care App

A comprehensive Flutter-based mobile application for menstrual health tracking, cycle predictions, doctor consultations, and health education. Built with Firebase backend for authentication and cloud data storage.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Step 1: Install Flutter SDK](#step-1-install-flutter-sdk)
- [Step 2: Install Android Studio & SDK](#step-2-install-android-studio--android-sdk)
- [Step 3: Install Node.js & Firebase CLI](#step-3-install-nodejs--firebase-cli)
- [Step 4: Clone the Repository](#step-4-clone-the-repository)
- [Step 5: Firebase Project Setup](#step-5-firebase-project-setup)
- [Step 6: Install Dependencies](#step-6-install-dependencies)
- [Step 7: Run the App](#step-7-run-the-app)
- [Step 8: Build Release APK](#step-8-build-release-apk)
- [Project Structure](#-project-structure)
- [Screenshots](#-screenshots)
- [Troubleshooting](#-troubleshooting)
- [License](#-license)

---

## ✨ Features

| Module | Description |
|---|---|
| 🔐 Auth | Email/Password signup & login with persistent sessions |
| 📊 Dashboard | Personalized greeting, cycle day counter, period predictions |
| 📝 Daily Log | Track bleeding flow, spotting, cramps, mood & notes |
| 📅 Cycle History | View past cycle data with charts (fl_chart) |
| 👩‍⚕️ Doctor Consultation | Browse doctors, chat (demo), book appointments |
| 💬 Chat Demo | Real-time chat UI with auto-reply simulation |
| 📚 Health Education | Articles on PCOS, PCOD, home remedies |
| ⏰ Reminders | Create custom reminders with notification settings |
| 👤 Profile | Personal info, health profile, help & privacy policy |
| 🌙 Dark Mode | Full dark/light theme toggle |

---

## 🛠 Tech Stack

| Technology | Purpose |
|---|---|
| [Flutter](https://flutter.dev/) `3.x` | Cross-platform UI framework |
| [Dart](https://dart.dev/) `>=3.0.0` | Programming language |
| [Firebase Auth](https://firebase.google.com/docs/auth) | User authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Cloud database |
| [Provider](https://pub.dev/packages/provider) | State management |
| [GoRouter](https://pub.dev/packages/go_router) | Declarative routing |
| [fl_chart](https://pub.dev/packages/fl_chart) | Charts & graphs |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Local storage |

---

## 📌 Prerequisites

Before starting, make sure you have the following installed on your system:

| Tool | Version | Download Link |
|---|---|---|
| **Git** | Latest | [https://git-scm.com/downloads](https://git-scm.com/downloads) |
| **Flutter SDK** | 3.x | [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install) |
| **Android Studio** | Latest | [https://developer.android.com/studio](https://developer.android.com/studio) |
| **Node.js** | 18+ | [https://nodejs.org/](https://nodejs.org/) |
| **VS Code** (recommended) | Latest | [https://code.visualstudio.com/](https://code.visualstudio.com/) |
| **Java JDK** | 17 | [https://adoptium.net/](https://adoptium.net/) |

---

## Step 1: Install Flutter SDK

### Windows

1. **Download** the Flutter SDK zip from:
   👉 [https://docs.flutter.dev/get-started/install/windows/mobile](https://docs.flutter.dev/get-started/install/windows/mobile)

2. **Extract** the zip to a location (do NOT put inside `Program Files`):
   ```
   C:\flutter
   ```

3. **Add Flutter to PATH**:
   - Press `Win + S` → Search "Environment Variables" → Open it
   - Under **User Variables**, find `Path` → Click **Edit**
   - Click **New** → Add: `C:\flutter\bin`
   - Click **OK** on all dialogs

4. **Restart your terminal** and verify:
   ```powershell
   flutter --version
   ```
   You should see output like: `Flutter 3.x.x • channel stable`

### macOS

```bash
# Using Homebrew (recommended)
brew install flutter

# Or download manually from https://docs.flutter.dev/get-started/install/macos
# Extract and add to PATH:
export PATH="$HOME/flutter/bin:$PATH"
```

### Linux

```bash
# Using snap (recommended)
sudo snap install flutter --classic

# Verify
flutter --version
```

---

## Step 2: Install Android Studio & Android SDK

1. **Download & Install Android Studio**:
   👉 [https://developer.android.com/studio](https://developer.android.com/studio)

2. **Open Android Studio** → Go to **Settings/Preferences** → **SDK Manager**

3. **Install these SDK components** (check the boxes):
   - ✅ Android SDK Platform 34 (or latest)
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android SDK Build-Tools 34
   - ✅ Android SDK Platform-Tools
   - ✅ Android Emulator (optional, for testing without a phone)

4. **Accept Android licenses**:
   ```powershell
   flutter doctor --android-licenses
   ```
   Type `y` to accept all licenses when prompted.

5. **Verify everything is set up correctly**:
   ```powershell
   flutter doctor
   ```
   You should see green checkmarks (✓) for Flutter and Android toolchain.

> 💡 **Tip**: If `flutter doctor` shows issues with Android SDK path, set it manually:
> ```powershell
> flutter config --android-sdk "C:\Users\<YourUsername>\AppData\Local\Android\Sdk"
> ```

---

## Step 3: Install Node.js & Firebase CLI

1. **Download & Install Node.js** (LTS version):
   👉 [https://nodejs.org/](https://nodejs.org/)

2. **Verify Node.js installation**:
   ```powershell
   node --version
   npm --version
   ```

3. **Install Firebase CLI globally**:
   ```powershell
   npm install -g firebase-tools
   ```

4. **Login to Firebase**:
   ```powershell
   firebase login
   ```
   This will open your browser — log in with your Google account.

5. **Install FlutterFire CLI**:
   ```powershell
   dart pub global activate flutterfire_cli
   ```

---

## Step 4: Clone the Repository

```powershell
# Clone the repository
git clone https://github.com/RohanKaranjee/nisarga-app.git

# Navigate into the project directory
cd nisarga-app
```

---

## Step 5: Firebase Project Setup

Since Firebase configuration files contain sensitive API keys, they are **excluded from the repository** via `.gitignore`. You need to create your own Firebase project and generate these files.

### 5.1 Create a Firebase Project

1. Go to 👉 [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `nisarga-app` (or any name you like)
4. Disable Google Analytics (optional) → Click **Create Project**

### 5.2 Enable Authentication

1. In Firebase Console → Go to **Authentication** (left sidebar)
2. Click **Get Started**
3. Enable **Email/Password** sign-in method
4. (Optional) Enable **Google Sign-In** if you want social login

### 5.3 Enable Cloud Firestore

1. In Firebase Console → Go to **Firestore Database** (left sidebar)
2. Click **Create Database**
3. Choose **Start in test mode** (for development)
4. Select your nearest region → Click **Enable**

### 5.4 Register Android App

1. In Firebase Console → Click the **gear icon ⚙️** → **Project Settings**
2. Scroll down → Click **Add App** → Select **Android** 🤖
3. Enter package name: `com.example.nisarga`
4. Enter app nickname: `Nisarga`
5. Click **Register App**
6. **Download `google-services.json`**
7. Place the file at:
   ```
   nisarga-app/android/app/google-services.json
   ```

### 5.5 Generate Firebase Options

Run the FlutterFire CLI to auto-generate the `firebase_options.dart` file:

```powershell
# Make sure you're in the project root directory
cd nisarga-app

# Configure Firebase for your project
flutterfire configure
```

This command will:
- Ask you to select your Firebase project
- Auto-detect platforms (select Android)
- Generate `lib/firebase_options.dart` with your project's configuration
- Update `android/app/google-services.json`

> ⚠️ **Important**: If `flutterfire` is not recognized, add Dart's global bin to your PATH:
> ```powershell
> # Windows
> set PATH=%PATH%;%LOCALAPPDATA%\Pub\Cache\bin
>
> # macOS/Linux
> export PATH="$PATH:$HOME/.pub-cache/bin"
> ```

---

## Step 6: Install Dependencies

```powershell
# Navigate to the project directory (if not already there)
cd nisarga-app

# Get all Flutter packages
flutter pub get
```

This will download all the packages listed in `pubspec.yaml`:
- `provider` — State management
- `go_router` — Navigation/routing
- `firebase_core` — Firebase initialization
- `firebase_auth` — Authentication
- `cloud_firestore` — Database
- `google_sign_in` — Google OAuth
- `fl_chart` — Charts
- `flutter_local_notifications` — Local notifications
- `shared_preferences` — Persistent local storage
- `intl` — Date formatting
- `flutter_svg` — SVG rendering
- `url_launcher` — Open URLs

---

## Step 7: Run the App

### Option A: Run on Physical Android Device (Recommended)

1. **Enable Developer Options** on your Android phone:
   - Go to **Settings** → **About Phone** → Tap **Build Number** 7 times
   
2. **Enable USB Debugging**:
   - Go to **Settings** → **Developer Options** → Enable **USB Debugging**

3. **Connect your phone** via USB cable

4. **Check connected devices**:
   ```powershell
   flutter devices
   ```
   You should see your phone listed.

5. **Run the app**:
   ```powershell
   flutter run
   ```

### Option B: Run on Android Emulator

1. Open **Android Studio** → **Device Manager** → **Create Virtual Device**
2. Select a phone (e.g., Pixel 7) → Download a system image → Finish
3. Start the emulator
4. Run:
   ```powershell
   flutter run
   ```

### Option C: Run in Debug Mode with Hot Reload

```powershell
flutter run --debug
```

Press `r` in the terminal for **hot reload** (instant UI updates).
Press `R` for **hot restart** (full app restart).
Press `q` to quit.

---

## Step 8: Build Release APK

### Build the APK

```powershell
flutter build apk
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on Connected Device

```powershell
flutter install
```

### Build APK with Split Per ABI (Smaller Size)

```powershell
flutter build apk --split-per-abi
```

This generates separate APKs for different CPU architectures:
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    (~20MB)
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  (~18MB)
build/app/outputs/flutter-apk/app-x86_64-release.apk       (~20MB)
```

> 💡 Most modern phones use `arm64-v8a`. Use that APK for the smallest file size.

---

## 📁 Project Structure

```
nisarga-app/
├── android/                    # Android native configuration
│   └── app/
│       ├── build.gradle.kts    # Android build config (Java 17, desugaring)
│       ├── google-services.json # Firebase config (YOU must add this)
│       └── src/
├── assets/
│   └── images/
│       ├── articles/           # Article header images
│       ├── doctors/            # Doctor profile images
│       ├── logo.png            # App logo
│       ├── banner.png          # Dashboard banner
│       └── test_icon.png       # App launcher icon
├── lib/
│   ├── main.dart               # App entry point (Firebase init)
│   ├── app.dart                # MaterialApp + Theme + Router setup
│   ├── firebase_options.dart   # Firebase config (auto-generated)
│   ├── core/
│   │   ├── constants/
│   │   │   └── colors.dart     # Color constants
│   │   ├── models/
│   │   │   ├── article.dart    # Article data model
│   │   │   ├── cycle_data.dart # Cycle tracking model
│   │   │   ├── daily_log.dart  # Daily symptom log model
│   │   │   ├── doctor.dart     # Doctor profile model
│   │   │   └── reminder.dart   # Reminder data model
│   │   ├── providers/
│   │   │   ├── auth_provider.dart    # Auth state + Firestore profile
│   │   │   ├── cycle_provider.dart   # Cycle tracking logic
│   │   │   ├── reminder_provider.dart# Reminder management
│   │   │   └── theme_provider.dart   # Dark/light mode toggle
│   │   ├── routes/
│   │   │   └── app_router.dart       # GoRouter route definitions
│   │   ├── services/
│   │   │   ├── auth_service.dart     # Firebase Auth wrapper
│   │   │   ├── firestore_service.dart# Firestore CRUD operations
│   │   │   └── notification_service.dart # Local notifications
│   │   └── theme/
│   │       ├── app_colors.dart       # App color palette
│   │       └── app_theme.dart        # ThemeData configuration
│   └── presentation/
│       ├── screens/
│       │   ├── auth/
│       │   │   ├── login_screen.dart      # Login page
│       │   │   └── register_screen.dart   # Signup with profile fields
│       │   ├── home/
│       │   │   └── home_screen.dart       # Main dashboard
│       │   ├── doctor/
│       │   │   ├── doctor_screen.dart      # Doctor listing
│       │   │   ├── doctor_detail_screen.dart # Doctor profile + booking
│       │   │   └── chat_demo_screen.dart   # Chat UI demo
│       │   ├── articles/
│       │   │   ├── articles_screen.dart    # Health articles list
│       │   │   └── article_detail_screen.dart # Article reader
│       │   ├── cycle_history/
│       │   │   └── cycle_history_screen.dart # Cycle charts
│       │   ├── reminders/
│       │   │   └── reminders_screen.dart   # Reminder management
│       │   ├── profile/
│       │   │   └── profile_screen.dart     # User profile & settings
│       │   ├── pcod/
│       │   │   └── pcod_screen.dart        # PCOD info screen
│       │   ├── pcos/
│       │   │   └── pcos_screen.dart        # PCOS info screen
│       │   ├── home_remedies/
│       │   │   └── home_remedies_screen.dart # Natural remedies
│       │   ├── onboarding/
│       │   │   └── onboarding_screen.dart  # First-time user onboarding
│       │   └── main_screen.dart            # Bottom nav shell
│       └── widgets/
│           ├── bottom_nav_bar.dart         # Bottom navigation bar
│           ├── daily_log_sheet.dart        # Daily logging bottom sheet
│           ├── expandable_section.dart     # Expandable FAQ widget
│           └── gradient_header.dart        # Gradient header component
├── pubspec.yaml                # Dependencies & assets config
├── pubspec.lock                # Locked dependency versions
└── README.md                   # This file
```

---

## 🖼 Screenshots

| Home Dashboard | Cycle Tracking | Doctor Consultation |
|---|---|---|
| Personalized greeting, cycle overview, quick actions | Daily log with mood, flow, cramps tracking | Browse doctors, chat, book appointments |

| Profile Settings | Health Articles | Reminders |
|---|---|---|
| Personal info, health profile, privacy policy | PCOS, PCOD, home remedies education | Custom reminders with notification controls |

---

## 🔧 Troubleshooting

### Common Issues & Solutions

#### ❌ `flutter: command not found`
**Solution**: Flutter is not in your PATH. Add `C:\flutter\bin` to your system PATH variable and restart your terminal.

#### ❌ `Android SDK not found`
**Solution**:
```powershell
flutter config --android-sdk "C:\Users\<YourUsername>\AppData\Local\Android\Sdk"
```

#### ❌ `No connected devices`
**Solution**: Make sure USB Debugging is enabled on your phone and run:
```powershell
flutter devices
```

#### ❌ `FAILURE: Build failed with an exception` (Gradle error)
**Solution**: Clean the build and try again:
```powershell
flutter clean
flutter pub get
flutter build apk
```

#### ❌ `firebase_options.dart` errors
**Solution**: You need to run FlutterFire configure to generate this file:
```powershell
flutterfire configure
```

#### ❌ `google-services.json` missing
**Solution**: Download it from Firebase Console → Project Settings → Android app → Download `google-services.json` and place it in `android/app/`.

#### ❌ Java version errors
**Solution**: This project requires Java 17. Install from [https://adoptium.net/](https://adoptium.net/) and set `JAVA_HOME`:
```powershell
# Windows
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.x.x-hotspot
```

#### ❌ `Execution failed for task ':app:compileFlutterBuildRelease'`
**Solution**: Usually a Dart code error. Run in debug mode first to see the exact error:
```powershell
flutter run --debug
```

---

## 🔄 Quick Reference — All Commands

```powershell
# ─── SETUP ─────────────────────────────────────
flutter --version                     # Check Flutter version
flutter doctor                        # Diagnose your setup
flutter doctor --android-licenses     # Accept Android licenses

# ─── PROJECT ───────────────────────────────────
git clone https://github.com/RohanKaranjee/nisarga-app.git
cd nisarga-app
flutter pub get                       # Install dependencies

# ─── FIREBASE ──────────────────────────────────
npm install -g firebase-tools         # Install Firebase CLI
firebase login                        # Login to Firebase
dart pub global activate flutterfire_cli
flutterfire configure                 # Generate firebase_options.dart

# ─── RUN ───────────────────────────────────────
flutter devices                       # List connected devices
flutter run                           # Run on connected device
flutter run --debug                   # Run in debug mode
flutter run --release                 # Run in release mode

# ─── BUILD ─────────────────────────────────────
flutter build apk                     # Build release APK
flutter build apk --split-per-abi     # Build smaller APKs
flutter install                       # Install APK on device

# ─── MAINTENANCE ───────────────────────────────
flutter clean                         # Clean build cache
flutter pub get                       # Re-fetch dependencies
flutter pub upgrade                   # Upgrade dependencies
```

---

## 📄 License

This project is developed as part of a **BCA Academic Project** by **Rohan Karanjee**.

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

**Made with ❤️ using Flutter & Firebase**
