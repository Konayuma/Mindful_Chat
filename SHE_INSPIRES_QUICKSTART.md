# She-Inspires Integration - Quick Start Guide

## 🚀 Installation & Setup (5 Minutes)

### Step 1: Install Dependencies
```powershell
flutter pub get
```

### Step 2: Run Database Schema
1. Open Supabase Dashboard: https://wlpuqichfpxrwchzrdzz.supabase.co
2. Click **SQL Editor** → **New query**
3. Copy all contents from `she_inspires_schema.sql`
4. Paste and click **Run**
5. Wait for "Success. No rows returned" or success message

### Step 3: Configure Android Notifications (Optional)
Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>` tag:

```xml
<!-- Notification permissions for Android 13+ -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

### Step 4: Run the App
```powershell
flutter run
```

## 🎯 Quick Navigation Integration

### Add to Chat Screen
Add these navigation buttons to your chat screen:

```dart
// In chat_screen.dart AppBar actions
IconButton(
  icon: const Icon(Icons.wb_sunny),
  onPressed: () {
    Navigator.pushNamed(context, '/affirmation');
  },
  tooltip: 'Daily Affirmation',
),
IconButton(
  icon: const Icon(Icons.favorite),
  onPressed: () {
    Navigator.pushNamed(context, '/bookmarks');
  },
  tooltip: 'Favorites',
),
IconButton(
  icon: const Icon(Icons.book),
  onPressed: () {
    Navigator.pushNamed(context, '/journal');
  },
  tooltip: 'Journal',
),
```

### Or Create Navigation Drawer
```dart
Drawer(
  child: ListView(
    children: [
      const DrawerHeader(
        child: Text('Mindful Chat'),
      ),
      ListTile(
        leading: const Icon(Icons.chat),
        title: const Text('Chat'),
        onTap: () => Navigator.pushReplacementNamed(context, '/chat'),
      ),
      ListTile(
        leading: const Icon(Icons.wb_sunny),
        title: const Text('Daily Affirmation'),
        onTap: () => Navigator.pushNamed(context, '/affirmation'),
      ),
      ListTile(
        leading: const Icon(Icons.favorite),
        title: const Text('Favorites'),
        onTap: () => Navigator.pushNamed(context, '/bookmarks'),
      ),
      ListTile(
        leading: const Icon(Icons.book),
        title: const Text('Journal'),
        onTap: () => Navigator.pushNamed(context, '/journal'),
      ),
    ],
  ),
)
```

## 🧪 Testing the Features

### 1. Test Daily Affirmation
1. Open app and navigate to `/affirmation` route
2. You should see a beautiful affirmation card
3. Try these actions:
   - ✨ Click refresh icon (bottom left) for random affirmation
   - ❤️ Click heart icon to favorite/unfavorite
   - 📋 Click copy icon to copy to clipboard
   - 📤 Click share icon to share

### 2. Test Bookmarks
1. Navigate to `/bookmarks`
2. Switch between tabs: All, Affirmations, Messages, Journal
3. Search for keywords
4. View, copy, share, or delete bookmarks

### 3. Test Journal
1. Navigate to `/journal`
2. Click the + button to create a new entry
3. Write title and content
4. Click ✓ to save
5. Toggle between list and grid view
6. Edit or delete entries

### 4. Test Notifications (After setup)
1. Go to affirmation settings (not yet implemented, coming next)
2. Enable daily notifications
3. Set a time (e.g., 1 minute from now)
4. Wait for notification to appear
5. Tap notification to open app

## 📱 Available Routes

All routes are configured in `main.dart`:

- `/affirmation` - Daily Affirmation Screen
- `/bookmarks` - Bookmarks/Favorites Screen
- `/journal` - Journal/Notes Screen

## 🎨 Customization

### Change Primary Color
The affirmation cards and widgets use `Theme.of(context).colorScheme.primary` which is set to `#8FEC95` in main.dart. To change:

```dart
// In main.dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF8FEC95), // Change this color
  brightness: Brightness.light,
),
```

### Customize Affirmations
Edit `assets/data/affirmations.json` to add/remove/modify affirmations:

```json
{
  "content": "Your custom affirmation text",
  "author": "Your Name",
  "category": "custom-category",
  "tags": ["tag1", "tag2"]
}
```

### Add More Categories
Categories are automatically detected from affirmations. Just add affirmations with new categories to expand the list.

## 🔔 Notification Setup Guide

### For Production Apps:

**Android:**
1. Add notification icon: `android/app/src/main/res/drawable/ic_notification.png`
2. Update `AndroidManifest.xml` (see Step 3 above)
3. Test on Android 13+ devices for permission handling

**iOS:**
1. Update `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 🐛 Troubleshooting

### Issue: "No affirmations available"
**Solution:** Check that `assets/data/affirmations.json` is included in `pubspec.yaml` under `assets:`

### Issue: Database error
**Solution:** Ensure you've run `she_inspires_schema.sql` in Supabase Dashboard

### Issue: Notifications not working
**Solution:** 
1. Check permissions are granted
2. For Android 13+, manually grant notification permission in Settings
3. Check `notification_enabled` is true in user preferences

### Issue: Bookmarks not syncing
**Solution:** Check internet connection and Supabase authentication status

## 📊 Next Features to Implement

1. **Affirmation Settings Screen** - Configure notifications
2. **Browse Affirmations Screen** - View all affirmations by category
3. **Mood-Based Affirmations** - Suggest affirmations based on mood tracking
4. **Chat Integration** - Bookmark AI responses directly from chat
5. **Widget** - Home screen widget for daily affirmation
6. **Export Journal** - Export journal entries as PDF/text

## 📚 Documentation Links

- [SHE_INSPIRES_INTEGRATION.md](./SHE_INSPIRES_INTEGRATION.md) - Full implementation details
- [FEATURE_INTEGRATION_PRD.md](./FEATURE_INTEGRATION_PRD.md) - Product requirements
- Supabase Schema: `she_inspires_schema.sql`
- Local Data: `assets/data/affirmations.json`

## 🎉 You're Ready!

All She-Inspires features are now integrated and ready to use. Start by navigating to the affirmation screen and exploring the features!

**Happy coding!** 💚✨
