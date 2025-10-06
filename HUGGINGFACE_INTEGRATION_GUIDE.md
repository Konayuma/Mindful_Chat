# Hugging Face Spaces Integration Guide

## 🎯 API Endpoint Configuration

### ✅ Current Configuration

**Base URL:** `https://sepokonayuma-mental-health-faq.hf.space`

**Protocol:** HTTPS only (no port numbers)

**Platform:** Hugging Face Spaces

---

## 📋 Configuration Details

### Base URL Settings

```dart
// ✅ CORRECT - Current configuration
static const String baseUrl = 'https://sepokonayuma-mental-health-faq.hf.space';
```

**Important Notes:**
- ✅ No port numbers (Hugging Face handles this automatically)
- ✅ No trailing slash
- ✅ HTTPS protocol only
- ✅ No `www` prefix

---

## 🔌 Available Endpoints

| Endpoint | Method | Purpose | Full URL |
|----------|--------|---------|----------|
| `/health` | GET | Check API health | `https://sepokonayuma-mental-health-faq.hf.space/health` |
| `/faq` | POST | Query the FAQ bot | `https://sepokonayuma-mental-health-faq.hf.space/faq` |
| `/api-info` | GET | Get API information | `https://sepokonayuma-mental-health-faq.hf.space/api-info` |
| `/docs` | GET | Interactive API docs | `https://sepokonayuma-mental-health-faq.hf.space/docs` |

---

## ⏱️ Timeout Configuration

**Cold Start Behavior:**
- Hugging Face Spaces may sleep after inactivity (free tier)
- First request can take **30-60 seconds** to wake up
- Subsequent requests are fast (< 2 seconds)

**Current Timeout Settings:**
```dart
// Query endpoint - 90 seconds
.timeout(const Duration(seconds: 90))

// Health check - 30 seconds
.timeout(const Duration(seconds: 30))
```

---

## 🧪 Testing the API

### 1. Browser Test (Health Check)
Open in your browser:
```
https://sepokonayuma-mental-health-faq.hf.space/health
```

Expected response:
```json
{
  "status": "healthy",
  "message": "FAQ Bot is ready",
  "model_loaded": true
}
```

### 2. API Documentation
View interactive docs:
```
https://sepokonayuma-mental-health-faq.hf.space/docs
```

### 3. Test Query with curl
```bash
curl -X POST https://sepokonayuma-mental-health-faq.hf.space/faq \
  -H "Content-Type: application/json" \
  -d '{"question":"What is anxiety?","top_k":3,"min_score":0.0}'
```

---

## 📱 Flutter App Integration

### Current Implementation

**File:** `lib/services/api_service.dart`

```dart
class ApiService {
  static const String baseUrl = 'https://sepokonayuma-mental-health-faq.hf.space';
  
  // Query FAQ
  static Future<List<dynamic>> queryFaq(String question, {
    int topK = 5,
    double minScore = 0.0,
  }) async {
    final uri = Uri.parse('$baseUrl/faq');
    // ... implementation with 90s timeout
  }
  
  // Health check
  static Future<Map<String, dynamic>> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');
    // ... implementation with 30s timeout
  }
}
```

---

## 🚀 User Experience

### Loading States

The app provides user feedback for cold starts:

```dart
// Welcome message
"⚠️ Note: The first question may take 30-60 seconds as the Hugging Face Space wakes up."

// Loading indicator
"Processing your question...
First query may take 30-60 seconds
(Server is waking up)"
```

### Error Handling

| Error Type | User Message |
|------------|--------------|
| Timeout | "Server is starting up. This can take 30-60 seconds on the first request. Please try again in a moment." |
| No Internet | "No internet connection. Please check your network and try again." |
| Server Error | "Failed to connect to server. Please try again later." |

---

## ✅ Advantages of Hugging Face Spaces

1. **Free Hosting** - No cost for hosting ML models
2. **GPU Support** - Can enable GPU acceleration if needed
3. **Automatic Scaling** - Handles traffic spikes
4. **Easy Deployment** - Git-based deployment
5. **Community Support** - Large ML community
6. **Built-in UI** - Gradio/Streamlit interfaces available

---

## 🔧 Configuration Files Updated

### Files Modified:

1. **`lib/services/api_service.dart`**
   - Updated base URL
   - Updated comments to reference Hugging Face Spaces

2. **`lib/screens/chat_screen.dart`**
   - Updated welcome message

3. **`HUGGINGFACE_INTEGRATION_GUIDE.md`**
   - New documentation file (this file)

---

## 📊 Performance Expectations

### Cold Start (Space was sleeping):
- First request: **30-60 seconds**
- Shows loading message to user
- Automatic retry available

### Warm State (Space is active):
- Subsequent requests: **1-3 seconds**
- Fast, responsive chat experience
- No loading delays

### Space Sleep Time:
- Hugging Face Spaces sleep after **~15 minutes** of inactivity
- First request after sleep wakes it up
- User sees appropriate loading message

---

## 🐛 Troubleshooting

### If connection fails:

1. **Check Space Status**
   - Visit: https://sepokonayuma-mental-health-faq.hf.space/health
   - If browser shows error, Space may be down or building

2. **Check Space Settings**
   - Go to Hugging Face Space settings
   - Ensure Space is set to "Running" (not paused)
   - Check if Space is public (not private)

3. **Test with curl**
   ```bash
   curl https://sepokonayuma-mental-health-faq.hf.space/health
   ```

4. **Check Flutter Logs**
   ```bash
   flutter run -v
   ```

5. **Verify HTTPS**
   - Ensure using `https://` not `http://`
   - No port numbers in URL

---

## 🔐 Security Notes

- ✅ HTTPS encryption for all requests
- ✅ No API keys needed (public Space)
- ✅ CORS configured on server side
- ✅ Secure token storage for user auth (Supabase)

---

## 📝 Migration from Render

### What Changed:

| Aspect | Render | Hugging Face Spaces |
|--------|--------|---------------------|
| Base URL | `https://slmchatcore.onrender.com` | `https://sepokonayuma-mental-health-faq.hf.space` |
| Cold Start | 30-60 seconds | 30-60 seconds |
| Platform | General web hosting | ML-specific hosting |
| Cost | Free tier with limits | Free for public Spaces |

### Why Hugging Face?

- Better suited for ML model hosting
- Larger free tier for ML workloads
- Built-in GPU support options
- ML community ecosystem
- Easier model deployment

---

## ✨ Next Steps

### Immediate:
- [x] Update API base URL
- [x] Update welcome messages
- [x] Test health endpoint
- [x] Test FAQ queries
- [ ] Monitor cold start times

### Future Enhancements:
- [ ] Enable GPU for faster responses
- [ ] Add model versioning
- [ ] Implement caching layer
- [ ] Add analytics tracking
- [ ] Set up monitoring dashboard

---

## 📞 Support Resources

- **Hugging Face Spaces Docs:** https://huggingface.co/docs/hub/spaces
- **API Endpoint:** https://sepokonayuma-mental-health-faq.hf.space
- **API Docs:** https://sepokonayuma-mental-health-faq.hf.space/docs

---

**Status:** ✅ Active and Running  
**Platform:** Hugging Face Spaces  
**Last Updated:** October 6, 2025  
**API Version:** 1.0  
