import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guradian_angel/Home.dart';
import 'package:guradian_angel/Menu.dart';
import 'SMS.dart';
import 'Location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';
import 'HomeFun.dart';
import 'record.dart';
import 'Portal.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'ChatScreen.dart';

class Lower extends StatefulWidget {
  final int selectedIndex;

  const Lower({super.key, this.selectedIndex = 0});

  @override
  State<Lower> createState() => _LowerState();
}

class _LowerState extends State<Lower> {
  late int _selectedIndex;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacity = 1.0);
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (context, darkMode, child) {

        final bgColor =
        darkMode ? Colors.grey[900] : Colors.white;

        final navIconColor =
        darkMode ? Colors.white70 : Colors.black54;

        final sirenBgColor =
        darkMode ? Colors.grey[800] : Colors.white;

        return AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,

          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,

            children: [

              // ---------------- BOTTOM NAV BAR ----------------
              Container(
                height: 65,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: bgColor,

                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: darkMode
                          ? Colors.black.withOpacity(0.6)
                          : Colors.black.withOpacity(0.1),

                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

                  children: [

                    // HOME
                    _buildNavIcon(
                      Icons.home,
                      0,
                          () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                        );
                      },
                      navIconColor,
                    ),

                    // LOCATION
                    _buildNavIcon(
                      Icons.location_on_rounded,
                      1,
                      _handleLocation,
                      navIconColor,
                    ),

                    SizedBox(width: screenWidth * 0.18),

                    // CHATBOT
                    _buildNavIcon(
                      Icons.smart_toy_outlined,
                      3,
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const ChatScreen(),
                          ),
                        );
                      },
                      navIconColor,
                    ),

                    // MENU
                    _buildNavIcon(
                      Icons.menu_rounded,
                      4,
                          () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(),
                          ),
                        );
                      },
                      navIconColor,
                    ),
                  ],
                ),
              ),

              // ---------------- CENTER SIREN BUTTON ----------------
              Positioned(
                top: -28,

                child: GestureDetector(
                  onTap: () => _onItemTapped(2),

                  child: Container(
                    height: 70,
                    width: 70,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sirenBgColor,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),

                    child: InkWell(
                      onTap: () async {
                        await FlutterPhoneDirectCaller
                            .callNumber("112");
                      },

                      child: Container(
                        margin: const EdgeInsets.all(6),

                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,

                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFA9271B),
                              Colors.redAccent,
                            ],

                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(10),

                          child: Image.asset(
                            "assets/images/siren.png",
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- NAV ICON ----------------
  Widget _buildNavIcon(
      IconData icon,
      int index,
      VoidCallback action,
      Color color,
      ) {

    final bool isSelected =
        _selectedIndex == index;

    return IconButton(
      iconSize: 26,

      icon: Icon(
        icon,
        color: isSelected
            ? const Color(0xFFA9271B)
            : color,
      ),

      splashRadius: 26,

      onPressed: () {
        _onItemTapped(index);
        action();
      },
    );
  }

  // ---------------- LOCATION FUNCTION ----------------
  Future<void> _handleLocation() async {

    List<double>? loc =
    await getCurrentCoordinates();

    if (loc == null || loc.length != 2) {

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
        "🚨 I am in danger! My current location: "
        "https://www.google.com/maps?q=$latitude,$longitude";

    final prefs =
    await SharedPreferences.getInstance();

    String phones =
        prefs.getString('contact_phones') ?? "";

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
            content:
            Text("WhatsApp is not installed"),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
          Text("Location sent to emergency contacts"),
        ),
      );
    }
  }
}