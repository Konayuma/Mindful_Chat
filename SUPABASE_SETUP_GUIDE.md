# Supabase Setup Guide

## 🚨 Fixing "SUPABASE NOT INITIALIZED" Error

The error occurs because your `.env` file is missing or not properly configured with your Supabase credentials.

## 📋 Quick Fix Steps

### 1. Create Your .env File
```bash
# In your project root directory, copy the example file:
cp .env.example .env
```

### 2. Get Your Supabase Credentials
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in or create a new account
3. Create a new project or select an existing one
4. Navigate to **Project Settings** → **API**
5. Copy the **Project URL** and **anon public** key

### 3. Update Your .env File
Replace the placeholder values in your `.env` file:

```env
# Supabase Configuration
SUPABASE_URL=https://your-actual-project-id.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key-here

# Gemini API Configuration (optional, for AI chat)
GEMINI_API_KEY=your-gemini-api-key-here

# Email Service Configuration (optional)
RESEND_API_KEY=re_your_api_key_here
EMAIL_FROM=onboarding@resend.dev
```

### 4. Restart Your App
After updating the `.env` file, restart your Flutter app:
```bash
flutter run
```

## 🔍 Detailed Setup

### Creating a New Supabase Project

1. **Sign Up**: Go to [supabase.com](https://supabase.com) and sign up
2. **New Project**: Click "New Project"
3. **Organization**: Select or create an organization
4. **Project Details**:
   - Name: `Mindful Chat`
   - Database Password: Create a strong password
   - Region: Choose closest to your users
5. **Wait**: Wait for project to be created (2-3 minutes)

### Finding Your Credentials

1. In your Supabase project dashboard
2. Click **Settings** (gear icon) in the sidebar
3. Select **API** from the menu
4. You'll find:
   - **Project URL**: `https://[project-id].supabase.co`
   - **API Keys**: Find the `anon` key (starts with `eyJ...`)

### Database Setup (Optional)

If you want to use the full chat features, you'll need to set up the database schema:

```sql
-- Create users table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE,
  display_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create conversations table
CREATE TABLE conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create messages table
CREATE TABLE messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_user_message BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
```

## 🐛 Troubleshooting

### Common Issues

1. **"SUPABASE NOT INITIALIZED"**
   - ✅ Check that `.env` file exists in project root
   - ✅ Verify credentials are correct (no trailing spaces)
   - ✅ Ensure URL format: `https://project-id.supabase.co`

2. **"Invalid API key"**
   - ✅ Use the `anon` key, not the `service_role` key
   - ✅ Copy the entire key without modifications

3. **"Connection failed"**
   - ✅ Check internet connection
   - ✅ Verify Supabase project is active
   - ✅ Ensure URL is correct

### Testing Your Setup

Run this simple test to verify your setup:

```dart
import 'package:flutter/material.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseService.initialize();
    print('✅ Supabase connected successfully!');
    
    // Test connection
    final client = SupabaseService.client;
    final response = await client.from('profiles').select('count');
    print('✅ Database connection working!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

## 📱 Minimum Viable Setup

For testing the home screen without full backend features:

1. **Skip Supabase**: Comment out the initialization in `main.dart` temporarily
2. **Use Mock Data**: The home screen works without authentication
3. **Focus on UI**: Test the UI components first

```dart
// In main.dart, temporarily comment out:
// await SupabaseService.initialize();
```

## 🆘 Get Help

If you're still having issues:

1. **Check the logs**: Look at the console output for specific error messages
2. **Verify credentials**: Double-check URL and key format
3. **Check network**: Ensure you can access supabase.com
4. **Restart app**: Sometimes a clean restart helps

## 📝 Next Steps

Once Supabase is working:

1. ✅ Test authentication flow
2. ✅ Set up database tables
3. ✅ Enable Row Level Security
4. ✅ Test chat functionality
5. ✅ Deploy to production

---

**Need help?** Check the console output for specific error messages and follow the troubleshooting steps above.
