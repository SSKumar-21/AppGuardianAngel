import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {

  // ---------------- API ----------------
  static Future<String> getBotReply(
      String userMessage,
      List<Map<String, String>> oldMessages,
      ) async {

    const String apiKey =
        "YOUR_API_KEY";

    try {

      List<Map<String, String>> apiMessages = [

        {
          "role": "system",

          "content": """
You are a Safety & Emergency Assistance Chatbot.

Your role is to provide clear, short, step-by-step actions in emergencies while also reassuring the user emotionally. Always assume the user may be in immediate danger.

🔹 Knowledge Domains

Emergency Guidance:
Govt protocols, survival guides, fire, accidents, harassment safety.

Self-Defence Awareness:
NGO awareness, safety methods, escape techniques.

Support Services:
Police, ambulance, women helplines, legal aid.

Medical & First Aid:
WHO and government first aid guidance.

Legal Information:
Women rights, harassment laws, victim protection acts.

If outside these domains reply:
"I’m designed to help with safety, emergency, legal, and awareness-related queries."

🔹 Rules

• Give immediate actions first
• Keep answers short
• Use steps
• Be calm and supportive
• Prioritize safety
• End with emotional reassurance
"""
        }
      ];

      // ADD OLD CHAT HISTORY
      apiMessages.addAll(oldMessages);

      // ADD NEW USER MESSAGE
      apiMessages.add({
        "role": "user",
        "content": userMessage,
      });

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

          "model": "llama-3.3-70b-versatile",

          "messages": apiMessages,

          "temperature": 0.7,

          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        return data['choices'][0]['message']['content']
            ?? "No response";
      }

      return
        "Server Error: ${response.statusCode}\n"
            "${response.body}";

    } catch (e) {

      return "Error: $e";
    }
  }

  // ---------------- SAVE CHAT ----------------
  static Future<void> saveChats(
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

  // ---------------- LOAD CHAT ----------------
  static Future<List<Map<String, String>>> loadSavedChats() async {

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
  static Future<void> clearChats() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove("chat_history");
  }
}