# Mental Health App

A Flutter mobile application designed to support mental health and wellness. This app provides tools for mood tracking, meditation, journaling, and accessing mental health resources with AI-powered chat support.

## ✨ Features

### Core Features
- **AI Chat Support**: Conversational AI assistant for mental health support
- **User Authentication**: Secure email/password authentication with Supabase
- **Mood Tracker**: Track your daily mood and emotional well-being
- **Journal**: Digital journaling for reflection and self-expression
- **Data Persistence**: All data securely stored in Supabase (PostgreSQL)
- **Real-time Sync**: Access your data across devices with real-time updates
- **Row Level Security**: Your data is protected and only accessible by you

### ✨ NEW: She-Inspires Features (Just Integrated!)
- **Daily Affirmations** 🌟: Start your day with positive mental health affirmations
- **Bookmarks/Favorites** 💾: Save and organize affirmations, messages, and journal entries
- **Enhanced Journal** 📓: Grid/list view, bookmarking, and improved editor
- **Daily Notifications** 🔔: Get reminded with daily affirmations at your preferred time
- **Share & Copy** 📤: Easily share inspiration with others
- **Search & Filter** 🔍: Find saved content and affirmations quickly

**See [INTEGRATION_COMPLETE.md](./INTEGRATION_COMPLETE.md) for setup instructions!**

## 🔧 Tech Stack

- **Frontend**: Flutter 3.6.0+
- **Backend**: Supabase (PostgreSQL database)
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Real-time**: Supabase Real-time subscriptions
- **Notifications**: Flutter Local Notifications
- **Sharing**: share_plus package
- **Storage**: SharedPreferences for offline support

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (version 3.6.0 or higher)
- Dart SDK
- Supabase account (free tier available)
- An IDE (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd MentalHealth
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. **Set up Supabase** (Required - One-time setup):
   
   a. Create a Supabase project at https://supabase.com
   
   b. Copy your credentials to `.env` file:
      ```bash
      SUPABASE_URL=https://your-project.supabase.co
      SUPABASE_ANON_KEY=your-anon-key-here
      ```
   
   c. Run database schema:
      - Open Supabase Dashboard → SQL Editor
      - Copy all content from `supabase_schema.sql`
      - Paste and run in SQL Editor
      - Wait for "Success. No rows returned"
   
   📖 **Detailed guide**: See `QUICK_START.md`

4. Run the app:
   ```bash
   flutter run
   ```

## 📋 Database Setup (IMPORTANT)

**REQUIRED BEFORE FIRST RUN:**

This app uses Supabase (PostgreSQL) for data storage. You must run the database schema once:

### Quick Setup:
1. Go to your Supabase Dashboard
2. Click "SQL Editor" → "New query"
3. Open `supabase_schema.sql` in VS Code
4. Copy all SQL code and paste into Supabase
5. Click "Run"

This creates:
- ✅ Database tables (users, conversations, messages, mood_entries, journal_entries)
- ✅ Row Level Security policies
- ✅ Automatic triggers
- ✅ Performance indexes

📖 **See `QUICK_START.md` for detailed instructions**

## 🏗️ Architecture

### Backend Services

- **SupabaseService** (`lib/services/supabase_service.dart`):
  - Main Supabase client singleton
  - Environment configuration
  - Helper methods for auth status

- **SupabaseAuthService** (`lib/services/supabase_auth_service.dart`):
  - User authentication (sign up, sign in, sign out)
  - Password management (reset, update)
  - Email updates
  - Auth state change streams

- **SupabaseDatabaseService** (`lib/services/supabase_database_service.dart`):
  - User profile management
  - Conversation and message storage with real-time updates
  - Mood tracking data
  - Journal entries
  - All CRUD operations

### Database Structure

```
PostgreSQL Tables (with Row Level Security):
├── users              # User profiles and settings
├── conversations      # Chat conversation metadata
├── messages           # Individual chat messages
├── mood_entries       # Mood tracking data with timestamps
└── journal_entries    # Personal journal entries with rich text
```

**Security**: All tables have Row Level Security (RLS) policies. Users can only access their own data.

**Real-time**: Uses Supabase Real-time for live updates on conversations and messages.

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

## 📂 Project Structure

```
lib/
├── main.dart                              # App entry point with Supabase init
├── screens/
│   ├── signin_screen.dart                 # Sign-in screen
│   ├── signup_screen.dart                 # Sign-up flow
│   ├── create_password_screen.dart        # Password creation
│   └── chat_screen.dart                   # AI chat interface
└── services/
    ├── supabase_service.dart              # Main Supabase client
    ├── supabase_auth_service.dart         # Authentication service
    ├── supabase_database_service.dart     # Database operations
    └── api_service.dart                   # External API calls

.env                                        # Environment variables (not in git)
.env.example                                # Template for .env
supabase_schema.sql                         # Database schema
QUICK_START.md                              # Quick start guide
MIGRATION_COMPLETE.md                       # Migration details
```

## 📚 Documentation

### Getting Started
- **`QUICK_START.md`** - Fast track to running the app
- **`INTEGRATION_COMPLETE.md`** - NEW: She-Inspires features setup (5 minutes)
- **`SHE_INSPIRES_QUICKSTART.md`** - Quick guide for new features

### Database & Migration
- **`supabase_schema.sql`** - Main database schema
- **`she_inspires_schema.sql`** - NEW: Affirmations & bookmarks schema
- **`MIGRATION_COMPLETE.md`** - Complete migration details
- **`SUPABASE_MIGRATION.md`** - Full migration guide

### Feature Documentation
- **`SHE_INSPIRES_INTEGRATION.md`** - NEW: Complete integration details
- **`FEATURE_INTEGRATION_PRD.md`** - Product requirements document

## 🧪 Development

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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Mental Health Resources](https://www.nami.org/)
