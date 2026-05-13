import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guradian_angel/Home.dart';
import 'package:guradian_angel/PersonalInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ChatScreen.dart';
import 'Location.dart';
import 'SMS.dart';
import 'call.dart';

import 'dart:ui';

class Upper extends StatefulWidget {
  const Upper({super.key});

  @override
  State<StatefulWidget> createState() => UpperState();
}

class UpperState extends State<Upper> {

  double _opacity = 0.0;

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();

    loadUserData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  // ---------------- LOAD USER DATA ----------------
  Future<void> loadUserData() async {

    final prefs =
    await SharedPreferences.getInstance();

    setState(() {

      userData = {

        "username":
        prefs.getString("username") ?? "User",

        "email":
        prefs.getString("email") ?? "",

        "password":
        prefs.getString("password") ?? "",

        "contact_names":
        prefs.getString("contact_names") ?? "",

        "contact_phones":
        prefs.getString("contact_phones") ?? "",

        "contact_relations":
        prefs.getString("contact_relations") ?? "",
      };
    });
  }

  // ---------------- CALL DIALOG ----------------
  void _showNumberDialog(BuildContext context) async {

    final prefs =
    await SharedPreferences.getInstance();

    String phones =
        prefs.getString("contact_phones") ?? "";

    String names =
        prefs.getString("contact_names") ?? "";

    String relations =
        prefs.getString("contact_relations") ?? "";

    if (phones.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No emergency numbers saved"),
        ),
      );

      return;
    }

    List<String> numbers =
    phones.split(',').map((e) => e.trim()).toList();

    List<String> nameList =
    names.split(',').map((e) => e.trim()).toList();

    List<String> relationList =
    relations.split(',').map((e) => e.trim()).toList();

    showDialog(
      context: context,

      builder: (context) {

        return BackdropFilter(

          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),

          child: AlertDialog(

            backgroundColor:
            Colors.black.withOpacity(0.6),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),

            title: Center(
              child: Text(
                "📞 Select Contact to Call",

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            content: SingleChildScrollView(
              child: Column(

                children: List.generate(
                  numbers.length,

                      (index) {

                    String name =
                    (index < nameList.length &&
                        nameList[index].isNotEmpty)
                        ? nameList[index]
                        : "Unknown";

                    String relation =
                    (index < relationList.length &&
                        relationList[index].isNotEmpty)
                        ? relationList[index]
                        : "Contact";

                    return Container(

                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),

                        borderRadius:
                        BorderRadius.circular(20),

                        border: Border.all(
                          color: Colors.white70,
                          width: 1.2,
                        ),
                      ),

                      child: ListTile(

                        leading: const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(
                            'assets/images/logo.jpeg',
                          ),
                        ),

                        title: Text(
                          name,

                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: Text(
                          "$relation • ${numbers[index]}",

                          style: GoogleFonts.poppins(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),

                        trailing: const Icon(
                          Icons.call_rounded,
                          color: Colors.redAccent,
                          size: 26,
                        ),

                        onTap: () {

                          Navigator.pop(context);

                          openDialPad(numbers[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (userData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return AnimatedOpacity(

      opacity: _opacity,

      duration: const Duration(seconds: 2),

      child: Container(

        height: 280,
        width: double.infinity,

        decoration: const BoxDecoration(

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              Color(0xFFA9271B),
              Color(0xFF000000),
            ],
          ),

          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // ---------------- HEADER ----------------
            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Text(
                  "Hello ${userData!['username']} 👋🏻",

                  style: GoogleFonts.dancingScript(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),

                GestureDetector(

                  onTap: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                            PersonalInfo(),
                      ),
                    );
                  },

                  child: const CircleAvatar(
                    radius: 20,

                    backgroundImage: AssetImage(
                      'assets/images/logo.jpeg',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "Emergency Helpline",

              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            Text(
              "24 × 7 Assistance",

              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- BUTTONS ----------------
            Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

              children: [

                // CALL BUTTON
                _buildButton(

                  label: "Call",

                  iconPath:
                  "assets/images/call.png",

                  onPressed: () =>
                      _showNumberDialog(context),
                ),

                // CHAT BUTTON
                _buildButton(

                  label: "Chat",

                  iconPath:
                  "assets/images/chat.png",

                  onPressed: () {

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (context) =>
                        const ChatScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // LOCATION BUTTON
            _buildButton(

              label: "Location",

              iconPath:
              "assets/images/location.png",

              onPressed: _handleLocation,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOCATION HANDLER ----------------
  Future<void> _handleLocation() async {

    List<double>? loc =
    await getCurrentCoordinates();

    if (loc == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Could not get your current location"),
        ),
      );

      return;
    }

    double latitude = loc[0];
    double longitude = loc[1];

    String message =
        "🚨 I am in danger! This is my Location: "
        "https://www.google.com/maps?q=$latitude,$longitude";

    String phones =
        userData!['contact_phones'] ?? "";

    // ---------------- WHATSAPP FALLBACK ----------------
    if (phones.trim().isEmpty) {

      final whatsappUrl = Uri.parse(
        "whatsapp://send?text=${Uri.encodeComponent(message)}",
      );

      if (await canLaunchUrl(whatsappUrl)) {

        await launchUrl(whatsappUrl);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "WhatsApp is not installed",
            ),
          ),
        );
      }

      return;
    }

    // ---------------- SEND SMS ----------------
    List<String> numbers =
    phones.split(',').map((e) => e.trim()).toList();

    for (String number in numbers) {

      await sendSms(number, message);
    }

    if (context.mounted) {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    }
  }

  // ---------------- BUTTON WIDGET ----------------
  Widget _buildButton({

    required String label,
    required String iconPath,
    required VoidCallback onPressed,

  }) {

    return OutlinedButton(

      onPressed: onPressed,

      style: OutlinedButton.styleFrom(

        fixedSize: const Size(140, 42),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),

        side: const BorderSide(
          color: Colors.white70,
          width: 1.3,
        ),

        backgroundColor:
        Colors.white.withOpacity(0.1),
      ),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Image.asset(
            iconPath,
            height: 20,
          ),

          const SizedBox(width: 10),

          Text(
            label,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}