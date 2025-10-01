# 🚀 Quick Start Guide - Firebase Setup

## ⚠️ Prerequisites Installation

### 1. Install Node.js (Required for Firebase CLI)

Download and install Node.js from: https://nodejs.org/
- Choose the LTS (Long Term Support) version
- Follow the installation wizard
- Verify installation:
  ```bash
  node --version
  npm --version
  ```

### 2. Install Firebase CLI

After Node.js is installed, run:

```bash
npm install -g firebase-tools
```

Verify Firebase CLI installation:
```bash
firebase --version
```

### 3. Install FlutterFire CLI (Already Done ✅)

```bash
dart pub global activate flutterfire_cli
```

Add Pub Cache to PATH if needed:
- Add `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin` to your system PATH

## 🔥 Firebase Configuration

### Step 1: Login to Firebase

```bash
firebase login
```

This will open a browser window for authentication.

### Step 2: Configure Firebase for Flutter

```bash
flutterfire configure
```

This interactive command will:
1. Ask you to select or create a Firebase project
2. Register your app with Firebase for all platforms
3. Generate `lib/firebase_options.dart` file
4. Download configuration files

**Recommended project name:** `mental-health-app` or similar

### Step 3: Update main.dart

After `firebase_options.dart` is generated, update the import in `lib/main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MentalHealthApp());
}
```

## 🎯 Firebase Console Setup

### 1. Enable Email/Password Authentication

1. Go to https://console.firebase.google.com
2. Select your project
3. Navigate to **Build** → **Authentication**
4. Click **Get Started**
5. Click **Email/Password**
6. Toggle **Enable**
7. Click **Save**

### 2. Create Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (easier for development)
4. Select a Cloud Firestore location (choose closest to your target users)
5. Click **Enable**

### 3. Set Up Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with the rules from `FIREBASE_SETUP.md`
3. Click **Publish**

## ✅ Verification Steps

### Test Firebase Connection

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Check for success message:
   ```
   Firebase initialized successfully
   ```

3. Try signing up with a test email:
   - Click "Sign Up"
   - Click "Continue with email"
   - Enter test email: `test@example.com`
   - Enter 6-digit code (shown in SnackBar)
   - Create a strong password
   - Click "Start My Journey"

4. Verify in Firebase Console:
   - Go to **Authentication** → **Users**
   - You should see your test user
   - Go to **Firestore Database** → **Data**
   - You should see a `users` collection with your user data

## 🐛 Troubleshooting

### "Firebase CLI not found"
- Install Node.js first
- Then install Firebase CLI: `npm install -g firebase-tools`
- Restart your terminal/PowerShell

### "flutterfire command not found"
- Run: `dart pub global activate flutterfire_cli`
- Add to PATH: `C:\Users\<Username>\AppData\Local\Pub\Cache\bin`
- Restart your terminal/PowerShell

### "Permission denied" on Windows
- Run PowerShell as Administrator
- Or use Command Prompt instead

### Firebase initialization fails
- Make sure `firebase_options.dart` was generated
- Check that the import is correct in `main.dart`
- Verify internet connection

## 📋 Current Status Checklist

- [ ] Node.js installed
- [ ] Firebase CLI installed
- [ ] FlutterFire CLI installed ✅
- [ ] Firebase project created
- [ ] `firebase_options.dart` generated
- [ ] Email/Password auth enabled
- [ ] Firestore database created
- [ ] Security rules configured
- [ ] Test user created successfully

## 🎉 Next Steps After Setup

Once Firebase is configured:

1. The sign-up flow will automatically:
   - Create Firebase Auth user
   - Store user profile in Firestore
   - Handle authentication

2. You can then:
   - Implement sign-in functionality
   - Build the chat interface with message persistence
   - Add mood tracking features
   - Add journal entries
   - All data will be stored in Firestore

## 📚 Helpful Commands

```bash
# Check Firebase CLI version
firebase --version

# Login to Firebase
firebase login

# Logout from Firebase
firebase logout

# List Firebase projects
firebase projects:list

# Configure FlutterFire
flutterfire configure

# Run Flutter app
flutter run

# Get Flutter dependencies
flutter pub get

# Clean Flutter build
flutter clean
```

## 🔗 Resources

- [Firebase Console](https://console.firebase.google.com)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase CLI Documentation](https://firebase.google.com/docs/cli)
- [Node.js Download](https://nodejs.org/)
