import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ---------------- API FUNCTION ----------------
Future<String> getBotReply(String message) async {

  const String apiKey =
      "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";

  try {

    final response = await http.post(

      Uri.parse(
        "https://api.groq.com/openai/v1/chat/completions",
      ),

      headers: {

        "Content-Type": "application/json",

        "Authorization":
        "Bearer $apiKey",
      },

      body: jsonEncode({

        // MODEL
        "model": "llama-3.3-70b-versatile",

        // CHAT HISTORY
        "messages": [

          {
            "role": "system",

            "content":
            "You are Guardian Angel AI, "
                "a helpful personal safety assistant. "
                "Help users calmly and clearly. "
                "Focus on safety, emergency guidance, "
                "mental support, and useful information.",
          },

          {
            "role": "user",
            "content": message,
          }
        ],

        // AI SETTINGS
        "temperature": 0.7,
        "max_tokens": 1024,
      }),
    );

    // SUCCESS
    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['choices'][0]['message']['content']
          ?? "No response";
    }

    // ERROR RESPONSE
    return
      "Server Error: ${response.statusCode}\n"
          "${response.body}";

  } catch (e) {

    return "Error: $e";
  }
}

// ---------------- SAVE CHATS ----------------
Future<void> saveChats(
    List<Map<String, String>> messages,
    ) async {

  final prefs =
  await SharedPreferences.getInstance();

  List<String> encoded = messages.map((msg) {

    return jsonEncode(msg);

  }).toList();

  await prefs.setStringList(
    "chat_history",
    encoded,
  );
}

// ---------------- LOAD CHATS ----------------
Future<List<Map<String, String>>> loadSavedChats() async {

  final prefs =
  await SharedPreferences.getInstance();

  List<String> savedChats =
      prefs.getStringList("chat_history") ?? [];

  return savedChats.map((chat) {

    return Map<String, String>.from(
      jsonDecode(chat),
    );

  }).toList();
}

// ---------------- CLEAR CHAT ----------------
Future<void> clearChats() async {

  final prefs =
  await SharedPreferences.getInstance();

  await prefs.remove("chat_history");
}