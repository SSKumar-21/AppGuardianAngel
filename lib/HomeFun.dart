
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> sendWhatsappFallback() async {
  final prefs = await SharedPreferences.getInstance();
  final phonesStr = prefs.getString("contact_phones") ?? "";
  final namesStr = prefs.getString("contact_names") ?? "";
  final id = prefs.getString("id") ?? "";

  final message = Uri.encodeComponent(
      "🚨I am in danger!\n📍 Live Tracking:\nhttps://livetrackingguardianangel.onrender.com/$id"
  );

  if (phonesStr.trim().isNotEmpty) {
    // ✅ Contacts found – log in console
    print("📱 Contacts found: $phonesStr");

    // Open WhatsApp with general message so user can pick contact
    final url = Uri.parse("https://wa.me/?text=$message");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("⚠️ Could not open WhatsApp.");
    }
  } else {
    // ❌ No contacts found – log in console
    print("❌ No contacts found. Opening WhatsApp fallback...");

    // Open WhatsApp fallback
    final url = Uri.parse("https://wa.me/?text=$message");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("⚠️ Could not open WhatsApp fallback.");
    }
  }
}
