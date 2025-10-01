# 🚀 Quick Start - Run Your App

## ⚠️ ONE-TIME SETUP REQUIRED

Before you can run your app, you MUST set up the database:

### 📊 Step 1: Run Database Schema (5 minutes)

1. **Open Supabase Dashboard**
   - Go to: https://wlpuqichfpxrwchzrdzz.supabase.co
   - Log in to your Supabase account

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar (📝 icon)
   - Click "New query" button

3. **Copy the Schema**
   - In VS Code, open: `supabase_schema.sql`
   - Select all (Ctrl+A)
   - Copy (Ctrl+C)

4. **Run the Schema**
   - Paste into Supabase SQL Editor (Ctrl+V)
   - Click "Run" button or press Ctrl+Enter
   - Wait for: **"Success. No rows returned"** ✅

5. **Verify Tables Created**
   - Click "Table Editor" in left sidebar
   - You should see these tables:
     - ✅ users
     - ✅ conversations
     - ✅ messages
     - ✅ mood_entries
     - ✅ journal_entries

---

## 🎯 Step 2: Run Your App

```bash
flutter run
```

Or press **F5** in VS Code.

---

## 🧪 Testing

### Create Account
1. Click "Create Account"
2. Enter email and password
3. Should see chat screen ✅

### Verify in Supabase
1. Go to Supabase Dashboard
2. Click "Authentication" → See your user
3. Click "Table Editor" → "users" → See your profile

### Sign In
1. Sign out from app
2. Sign in with your credentials
3. Should work perfectly ✅

---

## 🆘 If Something Goes Wrong

### "relation does not exist" error
→ You didn't run Step 1 (database schema)
→ Go back and run `supabase_schema.sql`

### "Invalid API key" error
→ Check your `.env` file has correct credentials
→ Restart the app

### Can't sign in
→ Check Supabase Dashboard → Logs for errors
→ Make sure email provider is enabled (it should be by default)

---

## ✅ You're All Set!

Once the schema is loaded, your app will:
- ✅ Sign up new users
- ✅ Sign in existing users
- ✅ Store user profiles automatically
- ✅ Use PostgreSQL database
- ✅ Have Row Level Security protecting data

Enjoy! 🎉
