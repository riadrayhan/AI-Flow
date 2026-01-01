import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/prompt_model.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> processText(String text, PromptModel prompt) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in environment');
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful writing assistant. Follow the user\'s instructions precisely.',
            },
            {
              'role': 'user',
              'content': '${prompt.instruction}:\n\n$text',
            }
          ],
          'max_tokens': 2048,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return content.toString().trim();
        }
        throw Exception('Empty response from API');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        debugPrint('Groq API Error: ${response.statusCode} - $errorMessage');
        throw Exception('API Error: $errorMessage');
      }
    } catch (e) {
      debugPrint('Groq Service Error: $e');
      rethrow;
    }
  }
}
