import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guradian_angel/Home.dart';
import 'package:flutter/services.dart';
import 'package:guradian_angel/HomeFun.dart';
import 'package:guradian_angel/Location.dart';
import 'package:guradian_angel/Menu.dart';
import 'package:guradian_angel/SMS.dart';
import 'package:guradian_angel/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fetchDATA.dart'; // import your try.dart file
import 'splash.dart';
import 'upper.dart';

// 🔹 Global dark mode notifier
ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // initialize Firebase

  bool isLogin = false;
  String email ="";
  String password = "";


  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xFFA9271B), // 🔴 your red color (#a9271b)
    statusBarIconBrightness: Brightness.light, // icons become white
    statusBarBrightness: Brightness.light, // for iOS
  ));

  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Load saved dark mode from SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  darkModeNotifier.value = prefs.getBool("isDark") ?? false;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Angel',
      home: Splash(),
    );
  }
}

class SmsSender {
  static const platform = MethodChannel('com.example.sms_sender');

  static Future<void> sendSms(List<String> numbers, String message) async {
    try {
      await platform.invokeMethod('sendSms', {
        'numbers': numbers,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Failed to send SMS: '${e.message}'.");
    }
  }
}
