import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  // ============================================================
  // GROQ API
  // ============================================================

  static const String _apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";

  // IMPORTANT:
  // Your API key has been exposed in the code you posted.
  // Revoke that key and create a new one.
  static const String _apiKey = "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";

  // Current replacement for the deprecated Llama 3.3 70B model.
  static const String _model = "openai/gpt-oss-120b";

  // ============================================================
  // GET BOT REPLY
  // ============================================================

  static Future<String> getBotReply(
      String userMessage,
      List<Map<String, String>> oldMessages,
      ) async {
    // ----------------------------------------------------------
    // EMPTY MESSAGE
    // ----------------------------------------------------------

    if (userMessage.trim().isEmpty) {
      return "Please describe your situation.";
    }

    // ----------------------------------------------------------
    // API KEY CHECK
    // ----------------------------------------------------------

    if (_apiKey.trim().isEmpty ||
        _apiKey == "YOUR_NEW_GROQ_API_KEY") {
      return "Groq API key is not configured.";
    }

    try {
      // ==========================================================
      // SYSTEM MESSAGE
      // ==========================================================

      final List<Map<String, String>> apiMessages = [
        {
          "role": "system",
          "content": """
You are a Safety & Emergency Assistance Chatbot.

Your role is to provide clear, short, step-by-step actions in
emergencies while also reassuring the user emotionally.

Always prioritize immediate safety.

KNOWLEDGE DOMAINS:

Emergency Guidance:
- Fire
- Accidents
- Harassment
- Emergency situations
- Survival guidance
- Government emergency procedures

Self-Defence Awareness:
- Personal safety
- Escape techniques
- Situational awareness
- Safety planning
- NGO awareness

Support Services:
- Police
- Ambulance
- Women helplines
- Emergency services
- Legal aid

Medical & First Aid:
- Basic first aid
- Emergency medical guidance
- When to seek professional medical help

Legal Information:
- Women rights
- Harassment
- Victim protection
- General legal awareness

RULES:

1. Give immediate safety actions first.
2. Keep answers short and practical.
3. Use numbered steps when possible.
4. Stay calm and supportive.
5. Never encourage dangerous actions.
6. If the user is in immediate danger, tell them to contact
   local emergency services or a trusted person.
7. Do not pretend to be police, a doctor, lawyer, or emergency
   responder.
8. Give general information and encourage professional help
   where appropriate.
9. End with a short reassuring sentence.

If the question is outside safety, emergency, legal,
medical first-aid, or awareness topics, reply:

"I'm designed to help with safety, emergency, legal,
and awareness-related queries."
"""
        }
      ];

      // ==========================================================
      // ADD ONLY VALID CHAT HISTORY
      // ==========================================================

      for (final message in oldMessages) {
        final role = message["role"];
        final content = message["content"];

        // Only send valid OpenAI/Groq message roles.
        if ((role == "user" || role == "assistant") &&
            content != null &&
            content.trim().isNotEmpty) {
          apiMessages.add({
            "role": role!,
            "content": content,
          });
        }
      }

      // ==========================================================
      // ADD CURRENT USER MESSAGE
      // ==========================================================

      apiMessages.add({
        "role": "user",
        "content": userMessage.trim(),
      });

      // ==========================================================
      // SEND REQUEST
      // ==========================================================

      final response = await http
          .post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
        },
        body: jsonEncode({
          "model": _model,
          "messages": apiMessages,

          "temperature": 0.7,

          "max_completion_tokens": 1024,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
      );

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data =
          jsonDecode(response.body);

          final choices = data["choices"];

          if (choices == null ||
              choices is! List ||
              choices.isEmpty) {
            print("Invalid Groq response:");
            print(response.body);

            return "Sorry, I received an invalid response.";
          }

          final message = choices[0]["message"];

          if (message == null) {
            return "Sorry, the AI response was invalid.";
          }

          final content = message["content"];

          if (content == null ||
              content.toString().trim().isEmpty) {
            return "Sorry, I received an empty response.";
          }

          return content.toString().trim();
        } catch (e) {
          print("Groq response parsing error: $e");
          print(response.body);

          return "Sorry, I could not understand the AI response.";
        }
      }

      // ==========================================================
      // 400 BAD REQUEST
      // ==========================================================

      if (response.statusCode == 400) {
        print("========== GROQ 400 ERROR ==========");
        print(response.body);

        try {
          final data = jsonDecode(response.body);

          final error = data["error"];

          if (error != null) {
            final message = error["message"];

            if (message != null) {
              return "Groq Error: $message";
            }
          }
        } catch (_) {}

        return "Invalid request sent to Groq.";
      }

      // ==========================================================
      // 401 API KEY
      // ==========================================================

      if (response.statusCode == 401) {
        print("========== GROQ 401 ERROR ==========");
        print(response.body);

        return "Invalid or expired Groq API key.";
      }

      // ==========================================================
      // 403 FORBIDDEN
      // ==========================================================

      if (response.statusCode == 403) {
        print("========== GROQ 403 ERROR ==========");
        print(response.body);

        return "Access to this Groq model was denied.";
      }

      // ==========================================================
      // 404 NOT FOUND
      // ==========================================================

      if (response.statusCode == 404) {
        print("========== GROQ 404 ERROR ==========");
        print(response.body);

        return "Groq API endpoint or model was not found.";
      }

      // ==========================================================
      // 429 RATE LIMIT
      // ==========================================================

      if (response.statusCode == 429) {
        print("========== GROQ 429 ERROR ==========");
        print(response.body);

        return "Too many requests. Please try again later.";
      }

      // ==========================================================
      // SERVER ERROR
      // ==========================================================

      if (response.statusCode >= 500) {
        print("========== GROQ SERVER ERROR ==========");
        print(response.body);

        return "Groq server is temporarily unavailable.";
      }

      // ==========================================================
      // OTHER ERROR
      // ==========================================================

      print("========== GROQ ERROR ==========");
      print("Status: ${response.statusCode}");
      print(response.body);

      return "Server Error: ${response.statusCode}";
    }

    // ==========================================================
    // TIMEOUT
    // ==========================================================

    on TimeoutException {
      return "The AI request took too long. Please try again.";
    }

    // ==========================================================
    // NETWORK ERROR
    // ==========================================================

    on Exception catch (e) {
      print("ChatService error: $e");

      return "Unable to connect to the AI. Please check your internet connection.";
    }
  }

  // ============================================================
  // SAVE CHAT
  // ============================================================

  static Future<void> saveChats(
      List<Map<String, String>> messages,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> encoded = messages.map((message) {
      return jsonEncode(message);
    }).toList();

    await prefs.setStringList(
      "chat_history",
      encoded,
    );
  }

  // ============================================================
  // LOAD CHAT
  // ============================================================

  static Future<List<Map<String, String>>> loadSavedChats() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> savedChats =
        prefs.getStringList("chat_history") ?? [];

    return savedChats.map((chat) {
      final decoded = jsonDecode(chat);

      return Map<String, String>.from(decoded);
    }).toList();
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  static Future<void> clearChats() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("chat_history");
  }
}