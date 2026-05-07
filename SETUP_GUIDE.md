# 🌿 Nisarga App — Complete Setup Guide (From Scratch)

> **For Students & New Developers**: This guide assumes you have a **brand new Windows PC** with nothing installed. Follow every step in order. Do NOT skip anything.

---

## 📋 What You Need Before Starting

- A **Windows 10 or 11** PC
- A **Gmail account** (for Firebase)
- An **Android phone** with a USB cable (for testing)
- A working **internet connection**
- At least **10 GB** of free disk space on your C:\ drive

---

## 🔢 TABLE OF CONTENTS

| Part | What You'll Do | Time |
|------|---------------|------|
| Part 1 | Install Git | 5 min |
| Part 2 | Install Node.js | 5 min |
| Part 3 | Install Java (JDK 17) | 5 min |
| Part 4 | Install Flutter SDK | 10 min |
| Part 5 | Install Android SDK (No Android Studio needed!) | 10 min |
| Part 6 | Enable Windows Developer Mode | 2 min |
| Part 7 | Create Firebase Project & Configure | 15 min |
| Part 8 | Connect Your Phone | 5 min |
| Part 9 | Run the App | 10 min |
| **Total** | | **~1 hour** |

---

# PART 1: Install Git

Git is needed to download the Flutter SDK.

1. Open your browser and go to: **https://git-scm.com/download/win**
2. Download the **64-bit** installer
3. Run the installer → click **Next** on every screen → click **Install**
4. Once installed, open **PowerShell** (search "PowerShell" in Start menu) and type:
   ```
   git --version
   ```
5. You should see something like `git version 2.43.0` — this means it's working ✅

---

# PART 2: Install Node.js

Node.js is needed for the Firebase CLI tool.

1. Open your browser and go to: **https://nodejs.org/**
2. Download the **LTS** version (the big green button on the left)
3. Run the installer → click **Next** on every screen → click **Install**
4. **Close and reopen PowerShell**, then type:
   ```
   node --version
   npm --version
   ```
5. You should see version numbers for both — this means it's working ✅

---

# PART 3: Install Java (JDK 17)

Java is needed by the Android compiler to build your app.

1. Open **PowerShell** and type:
   ```
   winget install Microsoft.OpenJDK.17
   ```
2. If it asks "Do you agree to all the source agreements?" type **Y** and press Enter
3. Wait for it to finish. You should see: `Successfully installed` ✅
4. **Close and reopen PowerShell**, then verify:
   ```
   java -version
   ```
5. You should see `openjdk version "17.x.x"` ✅

---

# PART 4: Install Flutter SDK

1. Open **PowerShell** and type:
   ```
   git clone https://github.com/flutter/flutter.git -b stable C:\flutter
   ```
2. Wait for it to finish downloading (~500 MB). This will take a few minutes.

3. Now add Flutter to your system PATH so you can use the `flutter` command from anywhere:

   **Option A (Using PowerShell — Recommended):**
   ```
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")
   ```

   **Option B (Manual way):**
   - Press **Windows key**, search for **"Environment Variables"** and open it
   - Under **User variables**, select **Path** and click **Edit**
   - Click **New** and type: `C:\flutter\bin`
   - Click **OK** → **OK** → **OK**

4. **Close and reopen PowerShell**, then verify:
   ```
   flutter --version
   ```
5. You should see `Flutter 3.x.x • channel stable` ✅

> **Note**: The first time you run `flutter`, it will download some extra components. This is normal and takes 1-2 minutes.

---

# PART 5: Install Android SDK (Without Android Studio)

You do NOT need to install the heavy Android Studio application. We only need the small command-line compiler tools.

### Step 5.1: Download Android Command Line Tools

1. Open your browser and go to: **https://developer.android.com/studio#command-line-tools-only**
2. Scroll down to **"Command line tools only"**
3. Download the **Windows** zip file
4. Create a folder: `C:\Android\cmdline-tools\latest`
5. Extract the **contents** of the zip file's `cmdline-tools` folder into `C:\Android\cmdline-tools\latest`

> **Important**: After extraction, the folder structure must look like this:
> ```
> C:\Android\cmdline-tools\latest\bin\sdkmanager.bat   ← This file must exist
> C:\Android\cmdline-tools\latest\lib\               ← This folder must exist
> ```

### Step 5.2: Install Android Platforms & Build Tools

1. Open **PowerShell** and run these commands one by one:
   ```
   C:\Android\cmdline-tools\latest\bin\sdkmanager.bat "platform-tools"
   ```
   Type **y** when asked to accept the license.

   ```
   C:\Android\cmdline-tools\latest\bin\sdkmanager.bat "platforms;android-34"
   ```

   ```
   C:\Android\cmdline-tools\latest\bin\sdkmanager.bat "build-tools;34.0.0"
   ```

### Step 5.3: Set the ANDROID_HOME Environment Variable

1. Open **PowerShell** and run:
   ```
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android", "User")
   ```

### Step 5.4: Tell Flutter Where the Android SDK Is

1. Run:
   ```
   flutter config --android-sdk C:\Android
   ```

### Step 5.5: Accept All Android Licenses

1. Run:
   ```
   flutter doctor --android-licenses
   ```
2. Type **y** and press Enter for every license that appears (there will be about 6 of them)

### Step 5.6: Verify Everything

1. Run:
   ```
   flutter doctor
   ```
2. You should see green checkmarks (✓) next to **Flutter** and **Android toolchain** ✅

   ```
   [✓] Flutter (Channel stable, 3.x.x)
   [✓] Android toolchain - develop for Android devices
   ```

---

# PART 6: Enable Windows Developer Mode

Flutter needs Developer Mode enabled to create necessary file links.

1. Press **Windows key** and search for **"Developer settings"**
2. Open **Developer Settings**
3. Find the toggle for **"Developer Mode"** and turn it **ON**
4. Click **Yes** when the confirmation popup appears

---

# PART 7: Firebase Setup

This is the most important part. Firebase provides login (Authentication) and database (Firestore) services for the app.

### Step 7.1: Install Firebase CLI

1. Open **PowerShell** and run:
   ```
   npm install -g firebase-tools
   ```
2. Wait for it to finish installing.

### Step 7.2: Log Into Firebase

1. Run:
   ```
   firebase login
   ```
2. A browser window will open. **Log in with your Gmail account**.
3. After logging in, go back to PowerShell. You should see: `✔ Success! Logged in as youremail@gmail.com` ✅

### Step 7.3: Create a Firebase Project

1. Run:
   ```
   firebase projects:create YOUR-PROJECT-NAME -n "Nisarga"
   ```
   Replace `YOUR-PROJECT-NAME` with a unique ID (only lowercase letters, numbers, and hyphens).
   Example:
   ```
   firebase projects:create nisarga-menstrual-health -n "Nisarga"
   ```
2. Wait for it to finish. You should see: `✔ Your Firebase project is ready!` ✅

### Step 7.4: Install FlutterFire CLI

1. Run:
   ```
   dart pub global activate flutterfire_cli
   ```

### Step 7.5: Configure FlutterFire

1. Navigate to the project folder:
   ```
   cd "PATH\TO\nisarga\nisarga"
   ```
2. Run:
   ```
   flutterfire configure -p YOUR-PROJECT-NAME
   ```
   Replace `YOUR-PROJECT-NAME` with the project ID you used in Step 7.3.

3. It will ask which platforms to configure. Just press **Enter** to select all defaults.

4. Wait for it to finish. It will generate a file called `lib/firebase_options.dart` ✅

### Step 7.6: Enable Authentication (in Browser)

1. Open your browser and go to:
   ```
   https://console.firebase.google.com/project/YOUR-PROJECT-NAME/overview
   ```
   (Replace `YOUR-PROJECT-NAME` with your actual project ID)

2. In the left sidebar, click **Security** → **Authentication**

3. Click the **"Get started"** button

4. **Enable Email/Password:**
   - Click on **"Email/Password"** in the list
   - Toggle the **first switch** to **ON**
   - Click **Save**

5. **Enable Google Sign-In:**
   - Click on **"Google"** in the list
   - Toggle the switch to **ON**
   - Select your email as the **"Project support email"**
   - Click **Save**

### Step 7.7: Create Firestore Database (in Browser)

1. In the Firebase Console left sidebar, click **Databases & Storage** → **Firestore Database**

2. Click **"Create database"**

3. **Location**: Select **asia-south1 (Mumbai)**

4. **Security Rules**: Select **"Start in test mode"**

5. Click **Create**

6. Wait for it to finish. You'll see an empty database when it's ready ✅

---

# PART 8: Connect Your Android Phone

### Step 8.1: Enable Developer Mode on Your Phone

1. Go to **Settings** → **About Phone**
2. Find **"Build Number"**
3. Tap on it **7 times quickly**
4. You'll see a message: *"You are now a developer!"* ✅

### Step 8.2: Enable USB Debugging

1. Go to **Settings** → **Developer Options** (this new menu item appears after Step 8.1)
2. Scroll down and find **"USB Debugging"**
3. Toggle it **ON**
4. Tap **OK** on the warning popup

### Step 8.3: Connect via USB

1. Plug your phone into your PC with a **USB cable**
2. On your phone screen, a popup will appear: **"Allow USB debugging?"**
3. Check the box **"Always allow from this computer"**
4. Tap **Allow**

### Step 8.4: Verify Connection

1. Open **PowerShell** and run:
   ```
   flutter devices
   ```
2. You should see your phone listed by its model name ✅

> **Tip**: If your phone is not showing up, try:
> - Using a **different USB cable** (some cables are charge-only)
> - Changing the USB mode on your phone to **"File Transfer"** instead of "Charging only"
> - Unplugging and plugging the cable again

---

# PART 9: Run the App! 🚀

1. Open **PowerShell** and navigate to the project:
   ```
   cd "PATH\TO\nisarga\nisarga"
   ```

2. Install all Dart packages:
   ```
   flutter pub get
   ```

3. Run the app:
   ```
   flutter run
   ```

4. If multiple devices are connected, it will ask you to choose. Type the number for your phone and press Enter.

5. **First time only**: The build will take **5-10 minutes** as it downloads Gradle and compiles the app. You'll see:
   ```
   Launching lib\main.dart on YOUR_PHONE in debug mode...
   Running Gradle task 'assembleDebug'...
   ```
   **Be patient. This is normal.**

6. Once it finishes, the app will install and launch on your phone automatically! 🎉

---

## ⚡ Useful Commands While the App is Running

Once the app is running, your terminal becomes an interactive controller:

| Key | Action |
|-----|--------|
| `r` | **Hot reload** — instantly applies code changes (< 1 second) |
| `R` | **Hot restart** — fully restarts the app with new code |
| `q` | **Quit** — stops the app |

---

## 🔧 Troubleshooting

### ❌ "flutter is not recognized"
**Fix**: Close your terminal and open a new one. If it still doesn't work, make sure `C:\flutter\bin` is in your system PATH (see Part 4, Step 3).

### ❌ Phone not showing in `flutter devices`
**Fix**: 
- Try a different USB cable (some are charge-only)
- Make sure USB Debugging is ON
- Change USB mode to "File Transfer" on your phone
- Install your phone's USB drivers from the manufacturer's website

### ❌ App crashes immediately after opening
**Fix**: Make sure you completed **all of Part 7** (Firebase setup). Both Authentication and Firestore must be enabled.

### ❌ Gradle build fails with errors
**Fix**: Run these commands:
```
flutter clean
flutter pub get
flutter run
```

### ❌ "Developer Mode is not enabled" error during `flutter pub get`
**Fix**: Go to Windows Settings → Developer Settings → Turn on Developer Mode (Part 6).

### ❌ Firebase errors in terminal
**Fix**: Make sure:
1. You ran `flutterfire configure` from inside the project folder
2. The file `lib/firebase_options.dart` exists
3. Authentication (Email/Password + Google) is enabled in Firebase Console
4. Firestore Database is created in Firebase Console

---

## 📁 Project Structure (For Reference)

```
nisarga/
├── lib/
│   ├── main.dart                ← App entry point
│   ├── app.dart                 ← Root app widget with routing
│   ├── firebase_options.dart    ← Auto-generated Firebase config
│   ├── core/
│   │   ├── providers/           ← State management (Auth, Cycle, Theme, Reminders)
│   │   ├── services/            ← Firebase Auth & Firestore logic
│   │   ├── theme/               ← App theme and colors
│   │   └── utils/               ← Helper functions
│   └── presentation/
│       └── screens/             ← All UI screens (Dashboard, Auth, Profile, etc.)
├── assets/
│   └── images/                  ← App images and icons
├── android/                     ← Android-specific build config
├── pubspec.yaml                 ← Project dependencies
└── SETUP_GUIDE.md               ← This file!
```

---

> **Made with ❤️ for BCA students — Nisarga Menstrual Health App**
