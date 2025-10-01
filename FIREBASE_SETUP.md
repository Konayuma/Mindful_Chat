# Firebase Setup Guide for Mental Health App

## 🔥 Firebase Configuration Steps

### Step 1: Install FlutterFire CLI

Run this command in your terminal:

```bash
dart pub global activate flutterfire_cli
```

### Step 2: Login to Firebase

```bash
firebase login
```

If you don't have Firebase CLI installed, install it first:
```bash
npm install -g firebase-tools
```

### Step 3: Configure Firebase for Your Flutter App

Run this command in the project root directory:

```bash
flutterfire configure
```

This will:
- Create a Firebase project (or select an existing one)
- Register your app with Firebase
- Generate `firebase_options.dart` file
- Download configuration files for all platforms

### Step 4: Enable Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Build** → **Authentication**
4. Click **Get Started**
5. Enable **Email/Password** authentication
6. (Optional) Enable **Google** sign-in if you want to use Google authentication

### Step 5: Create Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development) or **Start in production mode**
4. Select a location for your database (choose closest to your users)

### Step 6: Set Up Firestore Security Rules

In the Firebase Console under Firestore Database → Rules, use these security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isOwner(userId);
    }
    
    // Conversations collection
    match /conversations/{conversationId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated();
      allow update, delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Messages collection
    match /messages/{messageId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if isAuthenticated();
      allow delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Mood entries collection
    match /mood_entries/{entryId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow write: if isAuthenticated() && isOwner(resource.data.userId);
    }
    
    // Journal entries collection
    match /journal_entries/{entryId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow write: if isAuthenticated() && isOwner(resource.data.userId);
    }
  }
}
```

## 📊 Firestore Database Structure

### Collections:

#### 1. **users**
```
users/{userId}
  - userId: string
  - email: string
  - displayName: string
  - photoUrl: string
  - createdAt: timestamp
  - lastActive: timestamp
  - settings: map
    - notifications: boolean
    - theme: string
```

#### 2. **conversations**
```
conversations/{conversationId}
  - userId: string (owner)
  - title: string
  - createdAt: timestamp
  - updatedAt: timestamp
  - messageCount: number
```

#### 3. **messages**
```
messages/{messageId}
  - conversationId: string
  - userId: string
  - content: string
  - role: string ('user' | 'assistant')
  - timestamp: timestamp
  - metadata: map
```

#### 4. **mood_entries**
```
mood_entries/{entryId}
  - userId: string
  - mood: string
  - rating: number (1-5)
  - note: string
  - activities: array of strings
  - timestamp: timestamp
```

#### 5. **journal_entries**
```
journal_entries/{entryId}
  - userId: string
  - title: string
  - content: string
  - tags: array of strings
  - createdAt: timestamp
  - updatedAt: timestamp
```

## 🔧 Testing Firebase Connection

After configuration, run:

```bash
flutter run
```

Check the console for "Firebase initialized successfully" message.

## 📱 Platform-Specific Setup

### Android
- `google-services.json` will be added to `android/app/`
- No additional steps needed

### iOS
- `GoogleService-Info.plist` will be added to `ios/Runner/`
- No additional steps needed

### Web
- Firebase configuration will be added to `web/index.html`

## 🚀 Next Steps

1. Run `flutterfire configure`
2. Update the import in `main.dart`:
   ```dart
   import 'firebase_options.dart';
   
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```
3. Test the app and verify Firebase connection
4. Update the sign-up screens to use the AuthService

## 📚 Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Console](https://console.firebase.google.com)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
