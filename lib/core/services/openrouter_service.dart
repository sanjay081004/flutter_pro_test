import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _model = 'deepseek/deepseek-r1:free';

  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  Future<String> sendMessage(String message, {List<Map<String, String>>? conversationHistory}) async {
    try {
      // Prepare messages array
      List<Map<String, String>> messages = [];
      
      // Add conversation history if provided
      if (conversationHistory != null) {
        messages.addAll(conversationHistory);
      }
      
      // Add current user message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://flutter-pro-test.app', // Optional: for rankings
          'X-Title': 'Flutter Pro Test App', // Optional: for rankings
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          return data['choices'][0]['message']['content'] ?? 'No response received.';
        } else {
          return 'No response received from the AI.';
        }
      } else {
        debugPrint('OpenRouter API Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        
        if (response.statusCode == 401) {
          return 'Authentication failed. Please check the API key.';
        } else if (response.statusCode == 429) {
          return 'Rate limit exceeded. Please try again later.';
        } else if (response.statusCode >= 500) {
          return 'Server error. Please try again later.';
        } else {
          return 'Failed to get response from AI. Error: ${response.statusCode}';
        }
      }
    } catch (e) {
      debugPrint('OpenRouter Service Error: $e');
      return 'Network error. Please check your internet connection and try again.';
    }
  }

  // Get available models (optional feature)
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return (data['data'] as List)
              .map((model) => model['id'] as String)
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching models: $e');
      return [];
    }
  }

  // Check API status
  Future<bool> checkApiStatus() async {
    try {
      final response = await sendMessage('Hello');
      return !response.contains('error') && !response.contains('failed');
    } catch (e) {
      return false;
    }
  }
}
