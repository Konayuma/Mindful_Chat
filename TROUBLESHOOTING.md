# 🔧 Troubleshooting Guide

## Common Issues & Solutions

### ❌ Build Error: Resource compilation failed

**Problem**: `Resource compilation failed (path not found)`

**Solution**: Corrupted build cache
```bash
flutter clean
cd android
.\gradlew clean
cd ..
flutter pub get
flutter run
```

---

### ❌ Error: "relation does not exist" in Supabase

**Problem**: Database tables not created

**Solution**: Run the schema in Supabase Dashboard
1. Go to Supabase Dashboard → SQL Editor
2. Open `supabase_schema.sql`
3. Copy all content
4. Paste and run in SQL Editor
5. Wait for "Success. No rows returned"

---

### ❌ Error: "Invalid API key" or "Failed to initialize"

**Problem**: Missing or incorrect Supabase credentials

**Solution**: Check `.env` file
```bash
SUPABASE_URL=https://wlpuqichfpxrwchzrdzz.supabase.co
SUPABASE_ANON_KEY=your-actual-key-here
```

Make sure:
- ✅ No quotes around values
- ✅ No trailing spaces
- ✅ File is named exactly `.env` (not `.env.txt`)
- ✅ File is in project root (next to `pubspec.yaml`)

After fixing, restart the app:
```bash
flutter clean
flutter pub get
flutter run
```

---

### ❌ Error: "row-level security policy violated"

**Problem**: Trying to access data without authentication

**Solution**: Make sure user is signed in
- RLS policies require authentication
- Sign in before accessing database
- Check Supabase Dashboard → Authentication to see users

---

### ❌ App crashes on startup

**Problem**: Multiple possible causes

**Solutions**:
1. Check you ran `supabase_schema.sql` in Supabase Dashboard
2. Verify `.env` file has correct credentials
3. Check Supabase Dashboard → Logs for errors
4. Try:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

### ❌ "google-services.json not found" or Firebase errors

**Problem**: Old Firebase files still referenced

**Solution**: These files have been removed:
- ✅ Removed `firebase.json`
- ✅ Removed `firestore.rules`
- ✅ Removed `firestore.indexes.json`
- ✅ Removed `google-services.json`
- ✅ Removed Firebase gradle plugin from `build.gradle`

If you still see Firebase errors:
```bash
flutter clean
cd android
.\gradlew clean
cd ..
flutter pub get
flutter run
```

---

### ❌ Sign-up or Sign-in not working

**Problem**: Various causes

**Solutions**:

1. **Check Supabase Dashboard → Authentication**
   - Email provider should be enabled (it is by default)
   - Check for any error messages

2. **Check Supabase Dashboard → Logs**
   - Look for authentication errors
   - Look for database errors

3. **Verify database schema was run**
   - Go to Table Editor
   - Should see: users, conversations, messages, mood_entries, journal_entries

4. **Check app logs**
   - Look for error messages in terminal
   - `SupabaseAuthService` has detailed error messages

---

### ❌ Data not saving to database

**Problem**: RLS policies or incorrect service usage

**Solutions**:

1. **Verify user is authenticated**
   ```dart
   final isAuth = SupabaseService.instance.isAuthenticated;
   print('Is authenticated: $isAuth');
   ```

2. **Check RLS policies in Supabase**
   - Go to Table Editor → Select table → RLS tab
   - Policies should be enabled for authenticated users

3. **Check Supabase Dashboard → Logs**
   - Look for database errors
   - Look for RLS policy violations

---

### ⚠️ Gradle Build Taking Too Long

**Normal**: First build can take 3-5 minutes

**If stuck > 10 minutes**:
1. Stop the build (Ctrl+C)
2. Run:
   ```bash
   cd android
   .\gradlew clean
   .\gradlew --stop
   cd ..
   flutter clean
   flutter pub get
   flutter run
   ```

---

### 📱 Running on Different Devices

**List connected devices**:
```bash
flutter devices
```

**Run on specific device**:
```bash
flutter run -d <device-id>
```

**Run on Android emulator**:
1. Open Android Studio → AVD Manager
2. Start emulator
3. Run `flutter run`

---

## 🆘 Still Having Issues?

### Check These:

1. **Flutter doctor**
   ```bash
   flutter doctor -v
   ```
   Make sure all items have ✅

2. **Supabase Dashboard**
   - Project should be active (green status)
   - Go to Logs → See any errors?
   - Go to Authentication → See your users?
   - Go to Table Editor → See your tables?

3. **File Locations**
   - `.env` file exists in project root? ✅
   - `supabase_schema.sql` exists? ✅
   - `lib/services/supabase_service.dart` exists? ✅
   - `lib/services/supabase_auth_service.dart` exists? ✅
   - `lib/services/supabase_database_service.dart` exists? ✅

4. **Dependencies**
   ```bash
   flutter pub get
   ```
   Should complete without errors

---

## 📚 Useful Commands

**Clean everything**:
```bash
flutter clean
cd android
.\gradlew clean
cd ..
flutter pub get
```

**Check for errors**:
```bash
flutter analyze
```

**Check dependencies**:
```bash
flutter pub outdated
```

**Update dependencies**:
```bash
flutter pub upgrade
```

**Check Flutter setup**:
```bash
flutter doctor -v
```

**List devices**:
```bash
flutter devices
```

**Hot reload** (while app is running):
- Press `r` in terminal
- Or save file in VS Code

**Hot restart** (while app is running):
- Press `R` in terminal

---

## ✅ Verification Checklist

Before reporting an issue, verify:

- [ ] Ran `supabase_schema.sql` in Supabase Dashboard
- [ ] `.env` file exists with correct credentials
- [ ] Ran `flutter clean` and `flutter pub get`
- [ ] `flutter doctor` shows all checks passing
- [ ] Supabase project is active (check dashboard)
- [ ] No Firebase files remain (they've been deleted)
- [ ] Using Flutter 3.6.0 or higher (`flutter --version`)

---

## 🔍 Debug Mode

**Enable verbose logging** (while app is running):
1. Press `v` in terminal
2. See detailed logs
3. Press `v` again to disable

**See widget structure** (while app is running):
1. Press `w` in terminal
2. See widget tree
3. Press `w` again to disable

---

## 📞 Getting Help

If you're still stuck:

1. **Check Supabase Docs**
   - https://supabase.com/docs
   - https://supabase.com/docs/guides/getting-started/quickstarts/flutter

2. **Check Flutter Docs**
   - https://flutter.dev/docs

3. **Check the project docs**
   - `QUICK_START.md` - Quick setup guide
   - `MIGRATION_COMPLETE.md` - Full migration details
   - `SUPABASE_MIGRATION.md` - Complete migration guide

---

## 🎯 Quick Fix Summary

Most issues are solved by:

```bash
# Clean everything
flutter clean
cd android
.\gradlew clean
cd ..

# Reinstall dependencies
flutter pub get

# Run the app
flutter run
```

And making sure you ran `supabase_schema.sql` in Supabase Dashboard! ✅
