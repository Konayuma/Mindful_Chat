# Mental Health App

A Flutter mobile application designed to support mental health and wellness. This app provides tools for mood tracking, meditation, journaling, and accessing mental health resources with AI-powered chat support.

## Features

- **AI Chat Support**: Conversational AI assistant for mental health support
- **User Authentication**: Secure email/password and Google sign-in
- **Mood Tracker**: Track your daily mood and emotional well-being
- **Journal**: Digital journaling for reflection and self-expression with cloud sync
- **Data Persistence**: All data securely stored in Firebase Firestore
- **Real-time Sync**: Access your data across devices

## 🚀 Quick Start

### 1. Prerequisites

- Flutter SDK (version 3.6.0 or higher)
- Dart SDK
- **Node.js** (for Firebase CLI)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### 2. Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd MentalHealth
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (Required):
   - See `QUICKSTART.md` for detailed Firebase setup instructions
   - Install Node.js from https://nodejs.org/
   - Install Firebase CLI: `npm install -g firebase-tools`
   - Run: `flutterfire configure`

4. Run the app:
   ```bash
   flutter run
   ```

## 📋 Firebase Setup (IMPORTANT)

This app requires Firebase for authentication and data storage. Follow these steps:

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Configure Firebase for Flutter**:
   ```bash
   flutterfire configure
   ```

4. **Enable Authentication** in Firebase Console:
   - Go to Authentication → Get Started
   - Enable Email/Password authentication

5. **Create Firestore Database**:
   - Go to Firestore Database → Create Database
   - Start in test mode (for development)

For detailed instructions, see **QUICKSTART.md**

## 🏗️ Architecture

### Backend Services

- **AuthService** (`lib/services/auth_service.dart`):
  - User authentication (sign up, sign in, sign out)
  - Password management
  - Email verification

- **FirestoreService** (`lib/services/firestore_service.dart`):
  - User profile management
  - Conversation and message storage
  - Mood tracking data
  - Journal entries

### Database Structure

```
Firestore Collections:
├── users/              # User profiles and settings
├── conversations/      # Chat conversation metadata
├── messages/          # Individual chat messages
├── mood_entries/      # Mood tracking data
└── journal_entries/   # Personal journal entries
```

## 📱 Available Platforms

This app supports:
- Android
- iOS
- Windows (Desktop)
- macOS (Desktop)
- Web (Chrome, Edge)
- Linux (Desktop)

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Building for Production

For Android:
```bash
flutter build apk
```

For iOS:
```bash
flutter build ios
```

For Windows:
```bash
flutter build windows
```

## Project Structure

```
lib/
  main.dart          # Main application entry point
test/
  widget_test.dart   # Widget tests
android/             # Android-specific files
ios/                 # iOS-specific files
windows/             # Windows-specific files
macos/               # macOS-specific files
linux/               # Linux-specific files
web/                 # Web-specific files
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Mental Health Resources](https://www.nami.org/)
