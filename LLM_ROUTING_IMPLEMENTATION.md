# LLM Routing Implementation

## Overview
Successfully implemented a flexible LLM routing system that allows switching between multiple AI models in the Mental Health Chat application.

## Features Implemented

### 1. **LLM Service Layer** (`lib/services/llm_service.dart`)
- Centralized service for routing LLM requests
- Support for multiple AI models:
  - **Mindful Companion**: Your custom-trained SLM for mental health support
  - **Gemini Wisdom**: Google's Gemini Pro for broader insights
- Seamless model switching without code changes
- Context-aware conversations with message history

### 2. **Model Selection UI**
- **Dropdown Selector**: Clickable model name in the top navigation bar
- **Visual Indicator**: Chevron icon showing the dropdown is interactive
- **Modal Bottom Sheet**: Beautiful selection interface with:
  - Model icons (psychology icon for Mindful Companion, sparkle for Gemini)
  - Model descriptions
  - Visual selection indicator
  - Green highlight for selected model
- **Toast Notifications**: Confirmation when switching models

### 3. **Creative Model Names**
- **Mindful Companion**: "Your personalized mental health assistant"
  - Uses your custom-trained SLM via Hugging Face
  - Specialized in mental health topics
  - Icon: Psychology/brain icon
  
- **Gemini Wisdom**: "Powered by Google AI for broader insights"
  - Uses Google's Gemini Pro API
  - Better for general conversations
  - Icon: Auto-awesome/sparkle icon

## Technical Implementation

### Model Routing
```dart
enum LLMModel {
  mindfulCompanion('Mindful Companion', 'Your personalized mental health assistant'),
  geminiWisdom('Gemini Wisdom', 'Powered by Google AI for broader insights');
}
```

### API Integration
- **Gemini API Key**: `AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY` (hardcoded in service)
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`
- **Safety Settings**: Configured to block harmful content
- **Temperature**: 0.7 for balanced creativity
- **Max Tokens**: 1024 for comprehensive responses

### Context Management
- Maintains conversation history (last 6 messages)
- Passes context to both models for coherent conversations
- System prompt ensures mental health focus even with Gemini

### Error Handling
- Graceful fallback messages
- Rate limit detection
- Network error handling
- Timeout management (30s for Gemini, 90s for SLM)

## How to Use

### For Users:
1. Open the Mental Health Chat
2. Click on the model name at the top (e.g., "Mindful Companion")
3. A bottom sheet will appear with available models
4. Tap on your preferred model
5. Start chatting! Your selection persists during the session

### For Developers:
```dart
// Set model programmatically
LLMService.setModel(LLMModel.geminiWisdom);

// Send message with context
final response = await LLMService.sendMessage(
  userMessage,
  context: conversationHistory,
);
```

## Benefits

### 1. **Flexibility**
- Switch models without rebuilding the app
- Test different AI capabilities easily
- Use Gemini while training your SLM

### 2. **User Control**
- Users can choose their preferred AI experience
- Transparent model selection
- Clear indication of which model is active

### 3. **Development Efficiency**
- Easy to add new models in the future
- Centralized API management
- Consistent error handling

### 4. **Cost Management**
- Use free Gemini API for testing
- Switch to custom SLM when ready
- Control API usage per model

## Future Enhancements

### Potential Additions:
1. **Model Availability Status**
   - Show which models are online/offline
   - Disable unavailable models
   
2. **Model-Specific Settings**
   - Adjust temperature per model
   - Configure response length
   - Set creativity levels
   
3. **Usage Analytics**
   - Track which model is used more
   - Compare response quality
   - Monitor API costs
   
4. **More Models**
   - Add Claude, GPT-4, etc.
   - Support multiple Gemini versions
   - Local LLM options

5. **Smart Routing**
   - Auto-select best model based on query type
   - Fallback to alternative if primary fails
   - Load balancing across models

## Configuration

### API Keys
Currently, the Gemini API key is hardcoded in `lib/services/llm_service.dart`:
```dart
static const String _geminiApiKey = 'AIzaSyCutiFoAANsqE7x_GS80aU3q6uTHqGU4HY';
```

**Security Note**: For production, move this to environment variables:
1. Add to `.env` file
2. Load using `flutter_dotenv`
3. Never commit API keys to git

### Model URLs
- **SLM**: `https://sepokonayuma-mental-health-faq.hf.space`
- **Gemini**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent`

## Testing Checklist

- [x] Model selector UI renders correctly
- [x] Dropdown opens when clicked
- [x] Models display with correct names and descriptions
- [x] Model selection persists during chat session
- [x] Messages route to correct model
- [x] Context is passed between messages
- [x] Error messages are user-friendly
- [x] Toast notifications work
- [x] Connection status updates correctly
- [ ] Test with real Gemini API responses
- [ ] Test with SLM cold start scenarios
- [ ] Test model switching mid-conversation

## Files Modified

1. **Created**: `lib/services/llm_service.dart`
   - New service layer for LLM routing
   - Model enum and switching logic
   - API integration for Gemini

2. **Updated**: `lib/screens/chat_screen.dart`
   - Added model selector dropdown in top nav
   - Integrated LLM service for message sending
   - Added modal bottom sheet for model selection
   - Updated UI to show selected model name

## Commit Message Suggestion
```
feat: Add LLM routing with model selector

- Create LLMService with support for multiple AI models
- Add model selector dropdown in chat header
- Implement Gemini API integration
- Add beautiful model selection bottom sheet
- Support context-aware conversations
- Add creative model names (Mindful Companion, Gemini Wisdom)
- Maintain conversation history for better responses
```

---

**Status**: ✅ Implementation Complete  
**Testing**: 🟡 Needs real-world testing with both models  
**Documentation**: ✅ Complete
