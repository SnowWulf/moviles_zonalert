import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  static Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificaciones') ?? true;
  }
}
