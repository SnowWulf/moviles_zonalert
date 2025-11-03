import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class AlertHelper {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  /// Alerta de zona peligrosa
  static Future<void> showDangerAlert() async {
    // Vibración
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000);
    }

    // Notificación
    const androidDetails = AndroidNotificationDetails(
      'danger_zone_channel',
      'Zonas peligrosas',
      channelDescription: 'Alertas cuando estás cerca de una zona peligrosa',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      '⚠ Zona peligrosa detectada',
      'Ten precaución, estás cerca de una zona marcada como peligrosa.',
      notificationDetails,
    );
  }

  /// Notificación informativa general
  static Future<void> showInfoAlert(String titulo, String mensaje) async {
    const androidDetails = AndroidNotificationDetails(
      'info_channel',
      'Notificaciones ZonAlert',
      channelDescription: 'Notificaciones informativas del sistema',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      titulo,
      mensaje,
      notificationDetails,
    );
  }
}
