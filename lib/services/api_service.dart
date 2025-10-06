import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Model class for FAQ result items
class FaqResult {
  final String question;
  final String answer;
  final double score;
  final String category;

  FaqResult({
    required this.question,
    required this.answer,
    required this.score,
    required this.category,
  });

  factory FaqResult.fromJson(Map<String, dynamic> json) {
    return FaqResult(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'score': score,
      'category': category,
    };
  }
}

/// Model class for API query response
class FaqQueryResponse {
  final bool success;
  final List<FaqResult> results;
  final String message;
  final String query;
  final int totalResults;

  FaqQueryResponse({
    required this.success,
    required this.results,
    required this.message,
    required this.query,
    required this.totalResults,
  });

  factory FaqQueryResponse.fromJson(Map<String, dynamic> json) {
    return FaqQueryResponse(
      success: json['success'] ?? false,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => FaqResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] ?? '',
      query: json['query'] ?? '',
      totalResults: json['total_results'] ?? 0,
    );
  }
}

/// API Service for connecting to the deployed SLM FAQ bot on Hugging Face Spaces
/// 
/// Base URL: https://sepokonayuma-mental-health-faq.hf.space
/// Protocol: HTTPS only (no port numbers)
/// Timeout: 90 seconds (to handle Hugging Face Space cold starts)
class ApiService {
  // ✅ PRODUCTION URL - Hugging Face Spaces deployment (HTTPS, no port, no trailing slash)
  static const String baseUrl = 'https://sepokonayuma-mental-health-faq.hf.space';

  /// Query the FAQ bot with a question
  /// 
  /// [question] - The user's question
  /// [topK] - Number of top results to return (default: 5)
  /// [minScore] - Minimum similarity score (default: 0.0)
  /// [truncate] - Whether to truncate responses (default: false for full responses)
  /// [maxLength] - Maximum length of responses (default: 5000 for full responses)
  /// 
  /// Returns: FaqQueryResponse containing results, success status, and metadata
  /// 
  /// Throws:
  /// - [TimeoutException] if server takes too long (may be starting up)
  /// - [SocketException] if no internet connection
  /// - [Exception] for other errors
  static Future<FaqQueryResponse> queryFaq(
    String question, {
    int topK = 5,
    double minScore = 0.0,
    bool truncate = false,
    int maxLength = 5000,
  }) async {
    final uri = Uri.parse('$baseUrl/faq');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'top_k': topK,
          'min_score': minScore,
          'truncate': truncate,
          'max_length': maxLength,
        }),
      ).timeout(
        const Duration(seconds: 90), // ⚠️ Critical: Hugging Face Spaces may take 30-60s on cold start
        onTimeout: () {
          throw TimeoutException(
            'Server took too long to respond. It may be starting up. Please try again in a moment.',
          );
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return FaqQueryResponse.fromJson(data);
      } else {
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network and try again.');
    } on TimeoutException catch (e) {
      throw Exception(e.message ?? 'Request timed out');
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Check the health status of the API server
  /// 
  /// Returns: Map containing server status information
  /// - status: "healthy" if server is ready
  /// - message: Status message
  /// - model_loaded: Whether the AI model is loaded
  /// 
  /// Throws: Exception if health check fails
  static Future<Map<String, dynamic>> checkHealth() async {
    final uri = Uri.parse('$baseUrl/health');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Health check failed with status ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Cannot reach server. Please check your internet connection.');
    } on TimeoutException {
      throw Exception('Health check timed out. Server may be starting up.');
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }

  /// Get API information
  /// 
  /// Returns: Map containing API version and capabilities
  static Future<Map<String, dynamic>> getApiInfo() async {
    final uri = Uri.parse('$baseUrl/api-info');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get API info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get API info: $e');
    }
  }

  /// Get all FAQs (if endpoint exists on server)
  /// 
  /// Returns: List of all FAQ entries
  static Future<List<dynamic>> getAllFaqs() async {
    final uri = Uri.parse('$baseUrl/faqs');

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['faqs'] as List<dynamic>;
      } else {
        throw Exception('Failed to get FAQs: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Server may be starting up.');
    } catch (e) {
      throw Exception('Failed to get FAQs: $e');
    }
  }
}