import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatFun.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController controller =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  List<Map<String, String>> messages = [];

  bool isLoading = false;
  bool showIntro = true;
  bool darkMode = false;

  Map<String, dynamic> userData = {};

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  // ---------------- LOAD USER DATA ----------------
  Future<void> loadUserData() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {

      userData = {
        "id": prefs.getString("id") ?? "",
        "username": prefs.getString("username") ?? "",
        "email": prefs.getString("email") ?? "",
        "password": prefs.getString("password") ?? "",
        "address": prefs.getString("address") ?? "",
        "phone": prefs.getString("phone") ?? "",
        "contact_names": prefs.getString("contact_names") ?? "",
        "contact_phones": prefs.getString("contact_phones") ?? "",
        "contact_relations": prefs.getString("contact_relations") ?? "",
        "isDark": prefs.getBool("isDark") ?? false,
      };

      darkMode = prefs.getBool("isDark") ?? false;
    });
  }

  @override
  void initState() {
    super.initState();

    loadUserData();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(animationController);

    animationController.forward();

    Timer(const Duration(seconds: 2), () async {

      await loadChats();

      if (mounted) {
        setState(() {
          showIntro = false;
        });
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ---------------- SEND MESSAGE ----------------
  Future<void> sendMessage() async {

    String text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {

      messages.add({
        "role": "user",
        "text": text,
      });

      isLoading = true;
    });

    controller.clear();

    await ChatService.saveChats(messages);

    scrollToBottom();

    String botReply =
    await ChatService.getBotReply(
      text,
      messages,
    );

    setState(() {

      messages.add({
        "role": "assistant",
        "text": botReply,
      });

      isLoading = false;
    });

    await ChatService.saveChats(messages);

    scrollToBottom();
  }

  // ---------------- LOAD CHATS ----------------
  Future<void> loadChats() async {

    messages =
    await ChatService.loadSavedChats();

    setState(() {});
  }

  // ---------------- AUTO SCROLL ----------------
  void scrollToBottom() {

    Future.delayed(
      const Duration(milliseconds: 300),
          () {

        if (scrollController.hasClients) {

          scrollController.animateTo(
            scrollController.position.maxScrollExtent,

            duration:
            const Duration(milliseconds: 400),

            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ---------------- MESSAGE BUBBLE ----------------
  Widget buildMessage(Map<String, String> msg) {

    bool isUser = msg["role"] == "user";

    return Align(

      alignment:
      isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(

        constraints:
        const BoxConstraints(maxWidth: 280),

        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          gradient: isUser

              ? const LinearGradient(
            colors: [
              Color(0xFFA9271B),
              Colors.redAccent,
            ],
          )

              : LinearGradient(
            colors: darkMode
                ? [
              const Color(0xFF2A2A2A),
              const Color(0xFF1E1E1E),
            ]
                : [
              Colors.grey.shade200,
              Colors.grey.shade100,
            ],
          ),

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),

            bottomLeft:
            Radius.circular(isUser ? 18 : 0),

            bottomRight:
            Radius.circular(isUser ? 0 : 18),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Text(

          msg["text"] ?? "",

          style: GoogleFonts.poppins(
            color:
            isUser
                ? Colors.white
                : darkMode
                ? Colors.white
                : Colors.black87,

            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      darkMode
          ? const Color(0xFF121212)
          : Colors.white,

      appBar: AppBar(

        backgroundColor:
        darkMode
            ? Colors.black
            : const Color(0xFFA9271B),

        elevation: 0,

        title: Row(
          children: [

            const CircleAvatar(
              backgroundImage:
              AssetImage(
                'assets/images/logo.jpeg',
              ),
            ),

            const SizedBox(width: 12),

            Text(
              "Guardian Angel AI",

              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),

        actions: [

          IconButton(

            onPressed: () async {

              await ChatService.clearChats();

              setState(() {
                messages.clear();
              });
            },

            icon: const Icon(
              Icons.delete_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: showIntro

          ? Center(

        child: FadeTransition(

          opacity: fadeAnimation,

          child: ScaleTransition(

            scale: scaleAnimation,

            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                Container(

                  height: 150,
                  width: 150,

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.red.withOpacity(0.3),

                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "Guardian Angel AI",

                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFA9271B),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Your personal safety assistant",

                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                    darkMode
                        ? Colors.white70
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      )

          : Column(

        children: [

          Expanded(

            child: messages.isEmpty

                ? Center(

              child: Text(
                "Start chatting with Guardian Angel AI",

                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color:
                  darkMode
                      ? Colors.white54
                      : Colors.black45,
                ),
              ),
            )

                : ListView.builder(

              controller: scrollController,

              padding: const EdgeInsets.only(
                top: 12,
                bottom: 12,
              ),

              itemCount: messages.length,

              itemBuilder: (context, index) {

                return buildMessage(
                  messages[index],
                );
              },
            ),
          ),

          // ---------------- TYPING ----------------
          if (isLoading)

            Padding(

              padding:
              const EdgeInsets.only(bottom: 10),

              child: Text(
                "Guardian Angel AI is typing...",

                style: GoogleFonts.poppins(
                  color:
                  darkMode
                      ? Colors.white54
                      : Colors.black54,

                  fontSize: 13,
                ),
              ),
            ),

          // ---------------- INPUT AREA ----------------
          Container(

            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),

            decoration: BoxDecoration(

              color:
              darkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withOpacity(0.06),

                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),

            child: Row(
              children: [

                Expanded(

                  child: TextField(

                    controller: controller,

                    minLines: 1,
                    maxLines: 5,

                    style: GoogleFonts.poppins(
                      color:
                      darkMode
                          ? Colors.white
                          : Colors.black,
                    ),

                    decoration: InputDecoration(

                      hintText:
                      "Describe your situation...",

                      hintStyle:
                      GoogleFonts.poppins(
                        color:
                        darkMode
                            ? Colors.white54
                            : Colors.black54,
                      ),

                      filled: true,

                      fillColor:
                      darkMode
                          ? const Color(0xFF2A2A2A)
                          : Colors.grey.shade100,

                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(30),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(

                  onTap: sendMessage,

                  child: Container(

                    height: 52,
                    width: 52,

                    decoration: const BoxDecoration(

                      shape: BoxShape.circle,

                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFA9271B),
                          Colors.redAccent,
                        ],
                      ),
                    ),

                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}