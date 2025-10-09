import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

/// Enum representing available LLM models
enum LLMModel {
  /// Your custom-trained SLM for mental health support
  mindfulCompanion('Mindful Companion', 'Your personalized mental health assistant'),
  
  /// Google's Gemini Pro for general conversations
  geminiWisdom('Gemini Wisdom', 'Powered by Google AI for broader insights');

  final String displayName;
  final String description;
  
  const LLMModel(this.displayName, this.description);
}

/// Service that routes LLM requests to different AI models
/// Supports switching between custom SLM and Gemini API
class LLMService {
  // Gemini API configuration
  static String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  /// The currently selected model (defaults to custom SLM)
  static LLMModel _currentModel = LLMModel.mindfulCompanion;
  
  /// Get the current model
  static LLMModel get currentModel => _currentModel;
  
  /// Set the current model
  static void setModel(LLMModel model) {
    _currentModel = model;
  }
  
  /// Send a message to the currently selected LLM
  /// 
  /// [message] - The user's message/question
  /// [context] - Optional conversation context for better responses
  /// 
  /// Returns: AI-generated response as a String
  static Future<String> sendMessage(
    String message, {
    List<Map<String, String>>? context,
  }) async {
    // Apply guardrails: Check if query is within scope
    if (!_isWithinScope(message)) {
      return _getOutOfScopeResponse();
    }
    
    switch (_currentModel) {
      case LLMModel.mindfulCompanion:
        return await _callMindfulCompanion(message);
      case LLMModel.geminiWisdom:
        return await _callGemini(message, context: context);
    }
  }
  
  /// Check if the user's message is within the app's scope (mental health)
  static bool _isWithinScope(String message) {
    final lowercaseMessage = message.toLowerCase();
    
    // List of out-of-scope keywords/topics
    final outOfScopeKeywords = [
      // Programming/Tech (unless mental health related)
      'write code', 'programming', 'javascript', 'python', 'html', 'css',
      'algorithm', 'database', 'sql', 'api', 'github', 'coding',
      
      // Current events/Politics
      'election', 'president', 'politics', 'government', 'vote', 'politician',
      'war', 'military', 'terrorist',
      
      // Shopping/Commerce
      'buy', 'purchase', 'shop', 'price', 'discount', 'sale', 'order',
      'amazon', 'ebay', 'shopping',
      
      // Entertainment (unless therapy-related)
      'movie recommendation', 'tv show', 'netflix', 'game recommendation',
      'best movies', 'watch', 'streaming',
      
      // Weather
      'weather', 'temperature', 'forecast', 'rain', 'snow', 'sunny',
      
      // Sports
      'football score', 'basketball', 'baseball', 'soccer', 'sports team',
      'who won', 'game score',
      
      // Travel/Geography
      'flight', 'hotel', 'vacation', 'travel to', 'tourist', 'visa',
      'passport',
      
      // Food/Recipes (unless eating disorder related)
      'recipe for', 'how to cook', 'bake', 'restaurant', 'food delivery',
      
      // Science/Math (unless anxiety/stress related)
      'solve equation', 'calculate', 'physics', 'chemistry', 'biology',
      'mathematics',
      
      // Harmful/Illegal
      'how to harm', 'how to hurt', 'illegal', 'drugs', 'hack',
    ];
    
    // Check if message contains out-of-scope keywords
    for (var keyword in outOfScopeKeywords) {
      if (lowercaseMessage.contains(keyword)) {
        // Additional check: Allow if mental health context is clear
        if (!_hasMentalHealthContext(lowercaseMessage)) {
          return false;
        }
      }
    }
    
    // Check if message is too short or nonsensical
    if (message.trim().length < 3) {
      return false;
    }
    
    return true;
  }
  
  /// Check if message has mental health context
  static bool _hasMentalHealthContext(String message) {
    final mentalHealthKeywords = [
      'mental health', 'anxiety', 'depression', 'stress', 'therapy',
      'counseling', 'wellbeing', 'wellness', 'mood', 'emotion',
      'feeling', 'cope', 'coping', 'mental', 'psychological',
      'mindfulness', 'meditation', 'self-care', 'support',
      'struggling', 'overwhelmed', 'worried', 'fear', 'panic',
      'sad', 'lonely', 'exhausted', 'burnout', 'trauma',
    ];
    
    return mentalHealthKeywords.any((keyword) => message.contains(keyword));
  }
  
  /// Check if AI response has drifted off-topic (not mental health related)
  static bool _isResponseOffTopic(String response) {
    final lowerResponse = response.toLowerCase();
    
    // Red flags that indicate off-topic response
    final offTopicIndicators = [
      'recipe', 'ingredient', 'cooking', 'bake',
      'movie', 'film', 'tv show', 'watch',
      'weather forecast', 'temperature',
      'sports score', 'game result', 'team won',
      'buy', 'purchase', 'price', 'shopping',
      'code', 'function', 'variable', 'programming',
      'election', 'political', 'government',
    ];
    
    // Check if response contains multiple off-topic indicators
    int offTopicCount = 0;
    for (var indicator in offTopicIndicators) {
      if (lowerResponse.contains(indicator)) {
        offTopicCount++;
      }
    }
    
    // If response has 2+ off-topic indicators and no mental health context
    if (offTopicCount >= 2 && !_hasMentalHealthContext(lowerResponse)) {
      return true;
    }
    
    // Check if response is suspiciously short (likely deflecting)
    if (response.trim().length < 20) {
      return true;
    }
    
    return false;
  }
  
  /// Get response for out-of-scope queries
  static String _getOutOfScopeResponse() {
    return '''I'm specifically designed to help with mental health and wellbeing topics. 

I can assist you with:
• Managing stress and anxiety
• Coping strategies and self-care
• Understanding mental health conditions
• Mindfulness and relaxation techniques
• Emotional support and guidance
• Building healthy habits
• Improving sleep and rest
• Dealing with difficult emotions

Please feel free to ask me anything related to mental health and wellness! 🌟

If you're experiencing a mental health crisis, please contact:
• 933 - Lifeline Zambia (National Suicide Prevention Helpline)
• 116 - GBV and Child Protection Helpline
• 991 - Medical Emergency
• 999 - Police Emergency''';
  }
  
  /// Call your custom SLM (Mindful Companion)
  static Future<String> _callMindfulCompanion(String message) async {
    try {
      final response = await ApiService.queryFaq(
        message,
        topK: 3,
        minScore: 0.0,
        truncate: false,
        maxLength: 5000,
      );
      
      if (response.success && response.results.isNotEmpty) {
        // Combine top results into a cohesive response
        final topResult = response.results.first;
        return topResult.answer;
      } else {
        return "I'm here to help with mental health support. Could you please rephrase your question?";
      }
    } catch (e) {
      throw Exception('Mindful Companion error: $e');
    }
  }
  
  /// Call Google's Gemini API
  static Future<String> _callGemini(
    String message, {
    List<Map<String, String>>? context,
  }) async {
    final uri = Uri.parse(
      '$_geminiBaseUrl/gemini-2.5-flash:generateContent?key=$_geminiApiKey',
    );
    
    try {
      // Build conversation history
      final parts = <Map<String, dynamic>>[];
      
      // Add context if provided
      if (context != null && context.isNotEmpty) {
        for (var msg in context) {
          parts.add({
            'text': '${msg['role']}: ${msg['content']}',
          });
        }
      }
      
      // Add system prompt for mental health focus with strict guardrails
      final systemPrompt = '''You are a compassionate mental health support assistant in a dedicated mental health and wellness app.

STRICT SCOPE LIMITATIONS:
- You ONLY respond to questions about mental health, emotional wellbeing, stress, anxiety, depression, self-care, mindfulness, and related wellness topics.
- You MUST REFUSE to answer questions about: programming, current events, politics, shopping, weather, sports, entertainment recommendations, recipes, general knowledge, or any non-mental-health topics.
- If asked about topics outside mental health, politely redirect the user back to mental health topics.

YOUR ROLE:
- Provide empathetic, supportive responses for mental health concerns
- Offer evidence-based coping strategies and self-care advice
- Be kind, understanding, and non-judgmental
- Validate feelings while providing helpful guidance
- Always remind users you're an AI assistant, not a replacement for professional help
- Encourage seeking professional mental health services for serious concerns

RESPONSE GUIDELINES:
- Keep responses focused and relevant to mental health
- Use a warm, supportive tone
- Provide actionable advice when appropriate
- Include crisis resources when someone expresses severe distress
- Never provide medical diagnoses or prescribe treatments
- Stay within the scope of emotional support and general wellness advice

CRISIS RESOURCES (Zambia):
When users express severe distress or crisis, include these resources:
- 933 - Lifeline Zambia (National Suicide Prevention Helpline)
- 116 - GBV and Child Protection Helpline
- 991 - Medical Emergency
- 999 - Police Emergency

If a question is outside your scope, respond with:
"I'm here specifically to help with mental health and wellbeing. I can assist with [relevant topics]. Could you please ask me about a mental health or wellness concern?"''';
      
      parts.add({'text': systemPrompt});
      parts.add({'text': 'User: $message'});
      
      print('🔵 Sending to Gemini: $message');
      print('🔵 Context messages: ${context?.length ?? 0}');
      
      final requestBody = {
        'contents': [
          {
            'parts': parts,
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,  // Increased from 1024 for longer, more complete responses
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
        ],
      };
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Gemini API request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Check if response was blocked by safety filters
        if (data['promptFeedback'] != null) {
          final promptFeedback = data['promptFeedback'] as Map<String, dynamic>;
          if (promptFeedback['blockReason'] != null) {
            print('⚠️ Gemini blocked prompt: ${promptFeedback['blockReason']}');
            return _getOutOfScopeResponse();
          }
        }
        
        // Extract the generated text from Gemini's response
        if (data['candidates'] != null && 
            (data['candidates'] as List).isNotEmpty) {
          final candidate = (data['candidates'] as List)[0];
          
          // Check if this candidate was blocked
          if (candidate['finishReason'] == 'SAFETY') {
            print('⚠️ Gemini response blocked by safety filter');
            return _getOutOfScopeResponse();
          }
          
          final content = candidate['content'];
          if (content == null) {
            print('⚠️ Gemini returned null content');
            return "I apologize, but I couldn't generate a proper response. Please try rephrasing your question about mental health or wellbeing.";
          }
          
          final parts = content['parts'] as List?;
          if (parts == null || parts.isEmpty) {
            print('⚠️ Gemini returned no text parts');
            return "I apologize, but I couldn't generate a proper response. Please try rephrasing your question about mental health or wellbeing.";
          }
          
          final generatedText = parts[0]['text'] as String?;
          if (generatedText == null || generatedText.isEmpty) {
            print('⚠️ Gemini returned empty text');
            return "I apologize, but I couldn't generate a proper response. Please try rephrasing your question about mental health or wellbeing.";
          }
            
            // Additional safety check: Verify response is mental health focused
            if (_isResponseOffTopic(generatedText)) {
              print('⚠️ Gemini response deemed off-topic by guardrails');
              return _getOutOfScopeResponse();
            }
            
            print('✅ Gemini response: ${generatedText.substring(0, generatedText.length > 100 ? 100 : generatedText.length)}...');
            return generatedText;
          }
        
        print('⚠️ Gemini API response missing expected fields: $data');
        return "I apologize, but I couldn't generate a proper response. Please try again.";
      } else if (response.statusCode == 429) {
        throw Exception('API rate limit reached. Please try again in a moment.');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        final errorMessage = error['error']?['message'] ?? 'Unknown error';
        print('⚠️ Gemini 400 error: $errorMessage');
        print('⚠️ Full error response: ${response.body}');
        throw Exception('Invalid request: $errorMessage');
      } else {
        print('⚠️ Gemini API error ${response.statusCode}');
        print('⚠️ Response body: ${response.body}');
        throw Exception('Gemini API returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      throw Exception('Gemini error: $e');
    }
  }
  
  /// Check if a model is available and ready
  static Future<bool> checkModelAvailability(LLMModel model) async {
    switch (model) {
      case LLMModel.mindfulCompanion:
        try {
          final health = await ApiService.checkHealth();
          return health['status'] == 'healthy';
        } catch (e) {
          return false;
        }
      case LLMModel.geminiWisdom:
        // Gemini is available if we have internet and API key
        return _geminiApiKey.isNotEmpty;
    }
  }
  
  /// Get a user-friendly model description for the current model
  static String getCurrentModelDescription() {
    return _currentModel.description;
  }
}
