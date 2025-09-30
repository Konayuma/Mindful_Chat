import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // change baseUrl depending on emulator/device/ngrok
  static const String baseUrl = 'http://192.168.1.116:8000';

  static Future<List<dynamic>> queryFaq(String question) async {
    final uri = Uri.parse('$baseUrl/faq');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('API error: ${resp.statusCode} ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    return data['results'] as List<dynamic>;
  }

  static Future<List<dynamic>> getAllFaqs() async {
    final uri = Uri.parse('$baseUrl/faqs');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) throw Exception('API error');
    final data = jsonDecode(resp.body);
    return data['faqs'] as List<dynamic>;
  }
}