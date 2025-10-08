# Gemini Wisdom Model - Debug & Fix ✅

## 🐛 Problem Reported

**Issue:** Gemini Wisdom model giving "I'm sorry" message every time, not working properly.

**Expected:** Gemini should use the API to respond to mental health questions independently from Mindful Companion model.

---

## 🔍 Root Cause Analysis

### Potential Issues Identified:

1. **Safety Filter Blocks:** Gemini has strict safety filters that may block responses
2. **Missing Response Fields:** API might return unexpected response structure
3. **Null Content:** Response candidates might have null content
4. **Empty Text:** Generated text might be empty
5. **Off-Topic Guardrails:** Our guardrails might be too strict for Gemini
6. **Silent Failures:** Errors weren't being logged for debugging

---

## ✅ Fixes Applied

### 1. Enhanced Error Handling & Logging

Added comprehensive logging to track exactly what's happening:

```dart
// Before sending
print('🔵 Sending to Gemini: $message');
print('🔵 Context messages: ${context?.length ?? 0}');

// After receiving
print('✅ Gemini response: ${generatedText.substring(0, 100)}...');

// On errors
print('⚠️ Gemini blocked prompt: ${promptFeedback['blockReason']}');
print('⚠️ Gemini response blocked by safety filter');
print('⚠️ Gemini returned null content');
print('⚠️ Gemini returned empty text');
print('⚠️ Gemini 400 error: $errorMessage');
```

### 2. Safety Filter Detection

Added checks for Gemini's safety filters:

```dart
// Check prompt feedback
if (data['promptFeedback'] != null) {
  final promptFeedback = data['promptFeedback'] as Map<String, dynamic>;
  if (promptFeedback['blockReason'] != null) {
    print('⚠️ Gemini blocked prompt: ${promptFeedback['blockReason']}');
    return _getOutOfScopeResponse();
  }
}

// Check candidate finish reason
if (candidate['finishReason'] == 'SAFETY') {
  print('⚠️ Gemini response blocked by safety filter');
  return _getOutOfScopeResponse();
}
```

### 3. Null Safety Checks

Added null checks at every level:

```dart
// Check content exists
final content = candidate['content'];
if (content == null) {
  return "I apologize, but I couldn't generate a proper response...";
}

// Check parts exist
final parts = content['parts'] as List?;
if (parts == null || parts.isEmpty) {
  return "I apologize, but I couldn't generate a proper response...";
}

// Check text exists
final generatedText = parts[0]['text'] as String?;
if (generatedText == null || generatedText.isEmpty) {
  return "I apologize, but I couldn't generate a proper response...";
}
```

### 4. Improved Error Messages

Made error responses more user-friendly:

```dart
// Before:
return "I apologize, but I couldn't generate a proper response. Please try again.";

// After:
return "I apologize, but I couldn't generate a proper response. Please try rephrasing your question about mental health or wellbeing.";
```

### 5. Better HTTP Error Handling

Enhanced error messages for different status codes:

```dart
else if (response.statusCode == 400) {
  final error = jsonDecode(response.body);
  final errorMessage = error['error']?['message'] ?? 'Unknown error';
  print('⚠️ Gemini 400 error: $errorMessage');
  print('⚠️ Full error response: ${response.body}');
  throw Exception('Invalid request: $errorMessage');
}
```

---

## 🧪 How to Debug

### Step 1: Check Debug Console

When you send a message with Gemini Wisdom selected, watch for these logs:

```
🔵 Sending to Gemini: How do I manage anxiety?
🔵 Context messages: 2
```

### Step 2: Identify the Issue

Look for warning messages:

| Log Message | Meaning | Fix |
|-------------|---------|-----|
| `⚠️ Gemini blocked prompt` | Safety filter blocked | Rephrase question |
| `⚠️ Gemini response blocked by safety filter` | Response blocked | Question triggered filter |
| `⚠️ Gemini returned null content` | API response issue | Retry or contact Google |
| `⚠️ Gemini returned empty text` | Empty response | Retry |
| `⚠️ Gemini response deemed off-topic` | Our guardrails blocked | Question not mental health related |
| `⚠️ Gemini 400 error` | Bad request | Check API key or request format |

### Step 3: Successful Response

If working correctly, you'll see:

```
✅ Gemini response: I understand you're experiencing anxiety. Here are some evidence-based strategies that can help...
```

---

## 🔧 Testing Guide

### Test 1: Simple Mental Health Question
```
User: "How can I deal with stress?"
Expected: Gemini provides coping strategies
Debug: Check for ✅ or ⚠️ messages
```

### Test 2: Crisis Expression
```
User: "I'm feeling overwhelmed"
Expected: Supportive response with Zambian crisis resources
Debug: Should see Zambian numbers (933, 116, 991, 999)
```

### Test 3: Off-Topic Question
```
User: "What's the weather today?"
Expected: Out-of-scope redirect message
Debug: Should see "⚠️ Gemini response deemed off-topic" or pre-filter block
```

### Test 4: Empty Message
```
User: (empty)
Expected: No API call, button disabled
Debug: No logs should appear
```

---

## 🎯 Common Issues & Solutions

### Issue 1: Always Getting "I'm sorry" Message

**Symptoms:**
- Every Gemini response is error message
- No actual AI responses

**Debug:**
1. Check console for `⚠️` messages
2. Look for specific error type

**Solutions:**
- If `blocked prompt`: Question triggered safety filters → Rephrase
- If `null content`: API issue → Retry or check Gemini status
- If `empty text`: Response empty → Retry
- If `400 error`: Bad API key or request → Verify API key
- If `deemed off-topic`: Our guardrails → Ask mental health question

### Issue 2: API Key Not Working

**Symptoms:**
- 400 or 401 errors
- "Invalid API key" message

**Solution:**
```dart
// In llm_service.dart, verify:
static const String _geminiApiKey = 'AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY';

// Test key at: https://aistudio.google.com/app/apikey
```

### Issue 3: Safety Filters Too Strict

**Symptoms:**
- Legitimate mental health questions blocked
- Frequent safety filter warnings

**Solution:**
Adjust safety settings in `llm_service.dart`:

```dart
'safetySettings': [
  {
    'category': 'HARM_CATEGORY_HARASSMENT',
    'threshold': 'BLOCK_ONLY_HIGH',  // Changed from BLOCK_MEDIUM_AND_ABOVE
  },
  // ... repeat for other categories
],
```

### Issue 4: Guardrails Too Restrictive

**Symptoms:**
- Gemini responds but our code blocks it
- Seeing "⚠️ Gemini response deemed off-topic"

**Solution:**
Review `_isResponseOffTopic()` method and adjust thresholds:

```dart
// Current: 2+ off-topic indicators = blocked
if (offTopicCount >= 2 && !_hasMentalHealthContext(lowerResponse)) {
  return true;
}

// Try: 3+ off-topic indicators
if (offTopicCount >= 3 && !_hasMentalHealthContext(lowerResponse)) {
  return true;
}
```

---

## 📊 Expected API Flow

### Successful Request:
```
1. User types: "How do I manage anxiety?"
2. App checks: Is within scope? ✅ Yes
3. App sends to Gemini API with system prompt
4. Gemini processes with safety filters
5. Gemini returns response text
6. App checks: Off-topic? ❌ No
7. App displays response
8. User sees helpful anxiety management advice
```

### Blocked by Safety Filter:
```
1. User types: Question with sensitive terms
2. App checks: Is within scope? ✅ Yes
3. App sends to Gemini API
4. Gemini safety filter: ⚠️ BLOCKED
5. API returns: finishReason = "SAFETY"
6. App detects block
7. App shows: Out-of-scope message with crisis resources
```

### Blocked by Guardrails:
```
1. User types: "What's the weather?"
2. App checks: Is within scope? ❌ No
3. App immediately returns: Out-of-scope message
4. No API call made (saves quota)
5. User sees redirect to mental health topics
```

---

## 🚀 Next Steps to Test

### 1. Run the App
```bash
flutter run
```

### 2. Select Gemini Wisdom
- Tap "Mindful Companion" at top
- Select "Gemini Wisdom"
- Close model selector

### 3. Send Test Messages

**Test A - Simple Question:**
```
"How can I reduce stress?"
```
**Expected:** Helpful stress management advice

**Test B - Complex Question:**
```
"I've been feeling anxious lately and can't sleep well. What should I do?"
```
**Expected:** Comprehensive response about anxiety and sleep

**Test C - Crisis Expression:**
```
"I'm feeling really overwhelmed and don't know what to do"
```
**Expected:** Supportive response with Zambian crisis resources

**Test D - Off-Topic:**
```
"What's the capital of France?"
```
**Expected:** Out-of-scope message

### 4. Check Console Output

Watch for:
- 🔵 Blue messages: Normal flow
- ✅ Green messages: Success
- ⚠️ Warning messages: Issues detected

---

## 📝 Code Changes Summary

**File Modified:** `lib/services/llm_service.dart`

**Changes Made:**
1. ✅ Added safety filter detection
2. ✅ Added null safety checks at every level
3. ✅ Added comprehensive logging
4. ✅ Improved error messages
5. ✅ Enhanced HTTP error handling
6. ✅ Better user feedback

**Lines Modified:** ~40 lines in `_callGemini()` method

**Backward Compatible:** Yes, all existing functionality preserved

---

## 🎯 What Should Happen Now

### Before Fix:
```
User: "How do I manage anxiety?"
Gemini: "I'm sorry, I'm having trouble..."
Result: ❌ Not working
```

### After Fix:
```
User: "How do I manage anxiety?"
Console: 🔵 Sending to Gemini: How do I manage anxiety?
Console: ✅ Gemini response: I understand you're experiencing anxiety...
Gemini: [Helpful response about anxiety management]
Result: ✅ Working properly
```

---

## 🔍 If Still Not Working

### Check These in Order:

1. **API Key Valid?**
   - Test at https://aistudio.google.com/app/apikey
   - Should be: `AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY`

2. **Internet Connection?**
   - Gemini requires internet
   - Try pinging: `https://generativelanguage.googleapis.com`

3. **Console Logs?**
   - What's the last log message before error?
   - Is it 🔵, ⚠️, or error message?

4. **Model Selected?**
   - Is "Gemini Wisdom" showing at top?
   - Not "Mindful Companion"?

5. **Question Type?**
   - Is it mental health related?
   - Or off-topic (weather, sports, etc.)?

---

## 📞 Support

If Gemini still doesn't work after these fixes:

1. **Share Console Output:** Copy all 🔵 and ⚠️ messages
2. **Share Question Asked:** What did you type?
3. **Share Response Received:** What did Gemini say?
4. **Share Model Selected:** Gemini Wisdom or Mindful Companion?

This will help identify if it's:
- API issue (Google's side)
- Safety filter issue (question content)
- Guardrails issue (our code)
- Network issue (connectivity)

---

**Status:** Debug logging added ✅  
**Next:** Run app and check console for diagnostics  
**Expected:** Gemini should work or show clear error reason
