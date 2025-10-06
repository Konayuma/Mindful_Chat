# 🚀 Render API Integration - Complete Setup Guide

## ✅ Integration Status: COMPLETE

Your Flutter app is now configured to connect to the deployed SLM FAQ Bot API on Render!

---

## 📋 Configuration Summary

### API Endpoint
```
Base URL: https://slmchatcore.onrender.com
Protocol: HTTPS (secure)
Port: None (handled by Render)
Status: ✅ Configured
```

### Modified Files
1. **`lib/services/api_service.dart`** - Updated with Render URL and extended timeouts
2. **`lib/screens/chat_screen.dart`** - Enhanced UI with connection status and better error handling
3. **`lib/screens/api_test_screen.dart`** - NEW: Debug screen for testing connectivity

---

## 🎯 Key Features Implemented

### ✅ Production URL Configuration
- Base URL set to: `https://slmchatcore.onrender.com`
- No localhost references
- No port numbers
- HTTPS protocol only

### ✅ Extended Timeouts
- Query timeout: **90 seconds** (handles Render cold starts)
- Health check timeout: **30 seconds**
- First query can take 30-60 seconds when server wakes up

### ✅ Connection Status Indicator
- Real-time connection status in app bar
- Visual indicators: 🟢 Connected / 🔴 Offline / 🟠 Checking
- Manual refresh button to check connection

### ✅ Enhanced Error Handling
- User-friendly error messages
- Specific handling for:
  - No internet connection
  - Server timeout (cold start)
  - Network errors
  - Generic errors
- Retry functionality with snackbar actions

### ✅ Improved Loading States
- Typing indicator with animated dots
- Special message for first query (cold start warning)
- Clear visual feedback during processing

### ✅ Health Check Implementation
- `/health` endpoint to verify server status
- Automatic connection check on screen load
- Manual refresh capability

---

## 🧪 Testing Your Integration

### Method 1: Browser Test (Quick Verification)

**Test the API directly in your browser:**

1. **Health Check:**
   ```
   https://slmchatcore.onrender.com/health
   ```
   Expected response:
   ```json
   {
     "status": "healthy",
     "message": "FAQ Bot is ready",
     "model_loaded": true
   }
   ```

2. **Interactive API Docs:**
   ```
   https://slmchatcore.onrender.com/docs
   ```
   Try posting a test query here first!

### Method 2: In-App Debug Screen

1. Navigate to the API Test Screen (you can add a debug button to access it)
2. The screen will automatically run three tests:
   - ✅ Health Check
   - ✅ API Info
   - ✅ Sample Query
3. All tests should pass with green checkmarks

### Method 3: End-to-End User Flow

1. **Launch the App**
   - Welcome screen appears
   - Tap "Sign In" or "Sign Up"

2. **Navigate to Chat**
   - Sign in with your credentials
   - You'll see the chat screen

3. **Check Connection Status**
   - Look at the app bar
   - Should show: 🟢 "Connected"
   - If offline, tap the refresh button

4. **Send First Message**
   ```
   "What is anxiety?"
   ```
   - ⏱️ May take 30-60 seconds (server waking up)
   - Loading indicator shows: "Processing... First query may take 30-60 seconds"
   - Should receive relevant FAQ answers

5. **Send Second Message**
   ```
   "What is depression?"
   ```
   - ⚡ Should be fast (<2 seconds)
   - Receives immediate response

---

## 🔍 Expected Behavior

### ✅ First Query (Cold Start)
- **Duration:** 30-60 seconds
- **Loading Message:** "Processing your question... First query may take 30-60 seconds (Server is waking up)"
- **Result:** FAQ answers displayed in chat
- **Status:** Normal - Render free tier sleeps after inactivity

### ✅ Subsequent Queries
- **Duration:** <2 seconds
- **Loading Message:** "Thinking..."
- **Result:** Fast responses
- **Status:** Server is warm and ready

### ✅ Error Scenarios

#### No Internet Connection
```
Error: "I'm having trouble connecting. Please check your internet connection and try again."
Action: Check WiFi/mobile data
```

#### Server Timeout
```
Error: "The server is starting up. This can take 30-60 seconds... Please try again in a moment."
Action: Wait 30 seconds and retry
```

#### Server Unreachable
```
Error: "I can't reach the server right now..."
Action: Check https://slmchatcore.onrender.com/health in browser
```

---

## 📱 Platform-Specific Notes

### Android ✅
- Works out of the box
- HTTPS configured by default
- No special permissions needed

### iOS ✅
- Works out of the box
- App Transport Security allows HTTPS
- No configuration changes needed

### Web ✅
- CORS properly configured on server
- Should work without issues

---

## 🐛 Troubleshooting Guide

### Problem: "Lost connection to device" / App crashes on launch

**Solution:**
1. Check Supabase setup (run `supabase_schema.sql` in dashboard)
2. Verify `.env` file has correct Supabase credentials
3. Check if error occurs before or after reaching chat screen

### Problem: Connection shows "Offline" but internet works

**Solutions:**
1. Tap the refresh button in app bar
2. Check if server is up: https://slmchatcore.onrender.com/health
3. Check device internet permissions

### Problem: First query times out after 90 seconds

**Possible Causes:**
1. Server might be down (check URL in browser)
2. Network extremely slow
3. Firewall blocking HTTPS traffic

**Solutions:**
1. Verify server status: https://slmchatcore.onrender.com/health
2. Try on different network (WiFi vs mobile data)
3. Check device date/time settings (affects SSL)

### Problem: Getting 404 or 500 errors

**Check:**
1. Base URL is exactly: `https://slmchatcore.onrender.com`
2. No trailing slashes
3. No port numbers
4. Endpoint paths are correct: `/faq`, `/health`, `/api-info`

---

## 🔧 Advanced Configuration

### Adjust Timeout Duration

If you need to change timeout settings, edit `lib/services/api_service.dart`:

```dart
// For queries (currently 90 seconds)
.timeout(const Duration(seconds: 90))

// For health checks (currently 30 seconds)
.timeout(const Duration(seconds: 30))
```

### Add Debug Logging

Enable debug logging in `api_service.dart`:

```dart
import 'package:flutter/foundation.dart';

// Add before making HTTP request
if (kDebugMode) {
  print('API Call: $uri');
  print('Body: ${jsonEncode(requestBody)}');
}

// Add after receiving response
if (kDebugMode) {
  print('Response: ${response.statusCode}');
  print('Body: ${response.body}');
}
```

### Change API Base URL (if needed in future)

Edit `lib/services/api_service.dart`:

```dart
class ApiService {
  // Change this line only
  static const String baseUrl = 'https://your-new-url.com';
  // No trailing slash, no port, HTTPS only
}
```

---

## 📊 API Response Examples

### Successful FAQ Query
```json
{
  "question": "What is anxiety?",
  "top_results": [
    {
      "question": "What is anxiety?",
      "answer": "Anxiety is a normal emotion...",
      "score": 0.95,
      "question_id": "q_001"
    }
  ],
  "num_results": 1
}
```

### Health Check Response
```json
{
  "status": "healthy",
  "message": "FAQ Bot is ready",
  "model_loaded": true
}
```

---

## ✅ Validation Checklist

Run through this checklist to verify everything is working:

- [ ] Base URL is `https://slmchatcore.onrender.com` (no port)
- [ ] Browser test: Health endpoint returns `{"status":"healthy"}`
- [ ] App shows "Connected" status in chat screen
- [ ] First query completes (even if takes 60 seconds)
- [ ] Subsequent queries are fast (<2 seconds)
- [ ] Error messages are user-friendly
- [ ] Retry button works in error scenarios
- [ ] App works on WiFi
- [ ] App works on mobile data
- [ ] No localhost references in code
- [ ] No port numbers in URLs

---

## 🎓 Understanding Render Cold Starts

### Why does the first request take so long?

Render's free tier puts services to sleep after **15 minutes of inactivity**. When a request comes in:

1. **Render wakes up the container** (10-20 seconds)
2. **Python loads dependencies** (5-10 seconds)
3. **AI model loads into memory** (10-20 seconds)
4. **Request is processed** (1-2 seconds)

**Total:** 30-60 seconds

### After the first request:
- Server stays warm for 15 minutes
- Requests are instant (<2 seconds)
- No loading time for subsequent queries

---

## 📞 Support Resources

### If you encounter issues:

1. **Check Server Status:**
   - Visit: https://slmchatcore.onrender.com/health
   - Should show: `{"status":"healthy"}`

2. **Check API Documentation:**
   - Visit: https://slmchatcore.onrender.com/docs
   - Test endpoints directly

3. **Run Debug Tests:**
   - Use `ApiTestScreen` to diagnose issues
   - Check all three tests pass

4. **View Flutter Logs:**
   ```bash
   flutter run --verbose
   ```

---

## 🚀 You're All Set!

Your Flutter app is now fully integrated with the Render-deployed API. The configuration follows all best practices:

- ✅ Production-ready HTTPS URL
- ✅ Proper timeout handling
- ✅ User-friendly error messages
- ✅ Connection status monitoring
- ✅ Handles cold starts gracefully

**Test it out by asking mental health questions in the chat!**

---

## 📝 Quick Reference

| Item | Value |
|------|-------|
| **Base URL** | `https://slmchatcore.onrender.com` |
| **Health Check** | `GET /health` |
| **Query FAQ** | `POST /faq` |
| **API Docs** | `GET /docs` |
| **Query Timeout** | 90 seconds |
| **Health Timeout** | 30 seconds |
| **Cold Start Time** | 30-60 seconds |
| **Warm Request Time** | <2 seconds |

---

**Last Updated:** October 6, 2025  
**Integration Version:** 1.0  
**Status:** ✅ Production Ready
