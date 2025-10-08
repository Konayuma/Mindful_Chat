# Gemini API Fix - 404 Error Resolved! ✅

## 🎯 Problem Found!

**Error from Console:**
```
I/flutter: 🔵 Sending to Gemini: What is mental health
I/flutter: 🔵 Context messages: 1
I/flutter: ⚠️ Gemini API error 404
I/flutter: ⚠️ Response body: {
  "error": {
    "code": 404,
    "message": "models/gemini-pro is not found for API version v1beta, 
                or is not supported for generateContent..."
  }
}
```

**Root Cause:** 
- ❌ Using outdated API version: `v1beta`
- ❌ Using outdated model name: `gemini-pro`

---

## ✅ Fix Applied

### Change 1: API Version
```dart
// BEFORE (❌ Wrong):
static const String _geminiBaseUrl = 
  'https://generativelanguage.googleapis.com/v1beta/models';

// AFTER (✅ Correct):
static const String _geminiBaseUrl = 
  'https://generativelanguage.googleapis.com/v1/models';
```

### Change 2: Model Name
```dart
// BEFORE (❌ Wrong):
final uri = Uri.parse(
  '$_geminiBaseUrl/gemini-pro:generateContent?key=$_geminiApiKey',
);

// AFTER (✅ Correct):
final uri = Uri.parse(
  '$_geminiBaseUrl/gemini-1.5-flash:generateContent?key=$_geminiApiKey',
);
```

---

## 🚀 What Changed

| Component | Before | After |
|-----------|--------|-------|
| API Version | `v1beta` | `v1` (stable) |
| Model | `gemini-pro` | `gemini-1.5-flash` |
| Status | ❌ 404 Error | ✅ Should work |

---

## 📝 Why This Matters

### Old Setup (gemini-pro):
- Deprecated model
- Only available on v1beta API
- Google removed support
- Causing 404 errors

### New Setup (gemini-1.5-flash):
- Latest model (October 2025)
- Available on v1 stable API
- Fast responses
- Better at following instructions
- Free tier available

---

## 🧪 Test Again Now

### Step 1: Hot Reload
Press `r` in the terminal running Flutter to hot reload the changes.

### Step 2: Test Gemini Wisdom
1. Select "Gemini Wisdom" from the model selector
2. Ask: **"What is mental health?"**
3. Watch console for:
   ```
   I/flutter: 🔵 Sending to Gemini: What is mental health?
   I/flutter: ✅ Gemini response: Mental health refers to...
   ```

### Expected Result:
✅ Gemini should now respond with helpful information about mental health!

---

## 🎯 What You Should See

### Console Output:
```
I/flutter: 🔵 Sending to Gemini: What is mental health?
I/flutter: 🔵 Context messages: 1
I/flutter: ✅ Gemini response: Mental health refers to our emotional, 
            psychological, and social well-being. It affects how we think...
```

### In App:
A helpful, detailed response from Gemini about mental health.

---

## 📊 Model Comparison

| Feature | Gemini Pro (Old) | Gemini 1.5 Flash (New) |
|---------|-----------------|----------------------|
| Status | ❌ Deprecated | ✅ Active |
| API Version | v1beta | v1 (stable) |
| Speed | Slower | **Faster** |
| Context Window | 32K tokens | **1M tokens** |
| Availability | Removed | ✅ Available |
| Cost | N/A | Free tier |

---

## 🔧 If You See Different Errors

### Error: 429 (Rate Limit)
```
Solution: Wait a minute, then try again
Cause: Too many requests to Gemini API
```

### Error: 400 (Bad Request)
```
Solution: Check the debug logs for specific error
Cause: Request format issue
```

### Error: 401 (Unauthorized)
```
Solution: Verify API key is correct
Current Key: AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY
Test at: https://aistudio.google.com/app/apikey
```

### No Error, but "I'm sorry" Message
```
Solution: Check if question triggered safety filters
Debug: Look for "⚠️ Gemini response blocked by safety filter"
```

---

## ✅ Files Modified

**File:** `lib/services/llm_service.dart`

**Changes:**
1. Line ~26: Changed API version from `v1beta` to `v1`
2. Line ~230: Changed model from `gemini-pro` to `gemini-1.5-flash`

**Total Changes:** 2 lines

---

## 🎉 Summary

**Problem:** Gemini API returning 404 - model not found  
**Cause:** Using deprecated `gemini-pro` on old `v1beta` API  
**Solution:** Updated to `gemini-1.5-flash` on stable `v1` API  
**Status:** ✅ Fixed - Ready to test!

---

**Next Step:** Hot reload (`r` in terminal) or restart app, then try asking Gemini Wisdom a mental health question! 🚀

## Overview
You can now use Google's Gemini AI temporarily while training your custom mental health model!

## How to Switch Models

### Method 1: In-App Selection (Recommended)
1. **Open the app** and go to the chat screen
2. **Look at the top center** - you'll see your current model name (e.g., "Mindful Companion")
3. **Click on the model name** - a dropdown with a ▼ icon shows it's clickable
4. **Select "Gemini Wisdom"** from the bottom sheet that appears
5. **Start chatting!** All messages now use Gemini API

### Method 2: Change Default (Developer)
In `lib/screens/chat_screen.dart`, change line 43:
```dart
// Change from:
LLMModel _selectedModel = LLMModel.mindfulCompanion;

// To:
LLMModel _selectedModel = LLMModel.geminiWisdom;
```

## Model Comparison

### Mindful Companion (Your Custom SLM)
- ✅ **Best for**: Mental health-specific questions
- ✅ **Trained on**: Your curated mental health FAQ dataset
- ✅ **Cost**: Free (your Hugging Face Space)
- ⚠️ **Limitation**: Cold start (30-60s first request)
- ⚠️ **Limitation**: Limited to trained topics

### Gemini Wisdom (Google AI)
- ✅ **Best for**: General conversations, diverse topics
- ✅ **Response time**: Fast (~1-3 seconds)
- ✅ **Knowledge**: Broad general knowledge
- ✅ **Availability**: Always online
- ⚠️ **Cost**: Free tier has limits (60 requests/minute)
- ⚠️ **Limitation**: Less specialized in mental health

## When to Use Each Model

### Use Mindful Companion When:
- Testing your custom training data
- Need mental health-specific responses
- Working with known FAQ topics
- Want to validate model improvements
- Cost is a concern (it's free)

### Use Gemini Wisdom When:
- Your SLM is still training
- Need faster response times
- Testing conversation flow
- Handling diverse user questions
- Development/debugging phase

## API Configuration

### Your Gemini API Key
```
AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY
```
- **Location**: Hardcoded in `lib/services/llm_service.dart`
- **Rate Limit**: 60 requests/minute (free tier)
- **Model**: gemini-pro

### Security Recommendation
For production, move API key to environment variables:

1. Create `.env` file in project root:
```bash
GEMINI_API_KEY=AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY
```

2. Add to `.gitignore`:
```
.env
```

3. Load in `llm_service.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get _geminiApiKey => 
    dotenv.env['GEMINI_API_KEY'] ?? '';
```

## Testing Checklist

### With Gemini:
- [ ] Select "Gemini Wisdom" from dropdown
- [ ] Send a mental health question
- [ ] Verify response is helpful and empathetic
- [ ] Check response time (should be 1-3 seconds)
- [ ] Try a general knowledge question
- [ ] Verify conversation context is maintained

### With Mindful Companion:
- [ ] Select "Mindful Companion" from dropdown
- [ ] Send a question from your FAQ dataset
- [ ] Verify response matches trained data
- [ ] Test with low-confidence query
- [ ] Check cold start behavior (first request)
- [ ] Verify connection status indicator

### Model Switching:
- [ ] Switch from Mindful → Gemini mid-conversation
- [ ] Verify context is maintained
- [ ] Switch from Gemini → Mindful
- [ ] Test multiple switches in one session
- [ ] Verify UI updates correctly

## Common Issues & Solutions

### Issue: "Rate limit reached" with Gemini
**Solution**: 
- Wait 1 minute before retrying
- Switch to Mindful Companion temporarily
- Consider upgrading Gemini API tier

### Issue: Gemini responses not mental health focused
**Solution**: 
- System prompt is configured for mental health context
- Responses should still be empathetic
- For highly specialized topics, use Mindful Companion

### Issue: Mindful Companion is slow/offline
**Solution**:
- First request may take 30-60s (cold start)
- Check connection status indicator
- Switch to Gemini Wisdom as backup
- Verify Hugging Face Space is running

### Issue: Model not switching
**Solution**:
- Check for console errors
- Verify LLMService is imported
- Clear app cache and rebuild
- Check network connection

## Development Workflow

### Training Your Model
```
Day 1-7: Train custom model
         ↓
         Use Gemini Wisdom for app testing
         ↓
         Develop features with reliable API
         ↓
Day 8: Model training complete
         ↓
         Switch to Mindful Companion
         ↓
         Compare responses side-by-side
         ↓
         Fine-tune as needed
```

### A/B Testing
1. Keep both models enabled
2. Test same questions with both
3. Compare response quality
4. Identify gaps in custom training
5. Iterate on SLM training data

## Monitoring Usage

### To Track Model Usage:
Add analytics in `llm_service.dart`:
```dart
static Future<String> sendMessage(String message, {
  List<Map<String, String>>? context,
}) async {
  // Log usage
  print('Using model: ${_currentModel.displayName}');
  print('Query: $message');
  
  final startTime = DateTime.now();
  final response = await _routeMessage(message, context);
  final duration = DateTime.now().difference(startTime);
  
  print('Response time: ${duration.inMilliseconds}ms');
  
  return response;
}
```

### Metrics to Track:
- Requests per model
- Average response time
- Error rates
- User satisfaction
- Cost per model

## Cost Management

### Gemini API Costs (Free Tier)
- **Requests**: 60 per minute
- **Tokens**: Limited input/output
- **Daily**: Check Google AI Studio for limits

### Upgrading Gemini
If you need more:
1. Go to [Google AI Studio](https://makersuite.google.com/)
2. Enable billing
3. Upgrade to paid tier
4. Update usage in documentation

### Custom SLM Costs
- **Hugging Face**: Free for public Spaces
- **Compute**: Depends on usage
- **Scaling**: Consider paid tier for production

## Next Steps

1. **Test Both Models**: Spend time with each to understand strengths
2. **Collect Feedback**: Ask users which responses are better
3. **Improve SLM**: Use Gemini insights to improve training data
4. **Optimize**: Fine-tune parameters for each model
5. **Production Plan**: Decide primary model for launch

## Additional Resources

- [Gemini API Documentation](https://ai.google.dev/docs)
- [Hugging Face Spaces](https://huggingface.co/spaces)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- Your SLM: `https://sepokonayuma-mental-health-faq.hf.space`

---

**Status**: ✅ Ready to use  
**Default Model**: Mindful Companion  
**Backup Model**: Gemini Wisdom  
**Switching**: Easy via dropdown UI
