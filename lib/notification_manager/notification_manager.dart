import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  Future<void> initNotification() async {
    var initializationSettingsAndroid = AndroidInitializationSettings('icon_no_bg');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {});

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (details) {
        }
    );

  }

  Future<void> simpleNotificacitonShow() async {
    var permissions = await Permission.notification.status;
    print(permissions);
    if (permissions.isDenied) {
      await Permission.notification.request();
    }
    var androidNotificationDetails = const AndroidNotificationDetails(
      '1',
      'channelName1',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'icon_no_bg',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('icon_no_bg'),
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(1, 'Título de la Notificación', 'Cuerpo de la Notificación', notificationDetails);
  }

  Future<void> scheduleNotification(int id,String titulo, String cuerpo, DateTime hora) async {
    var permissions = await Permission.notification.status;
    print(permissions);
    if (permissions.isDenied) {
      await Permission.notification.request();
    }
    var androidNotificationDetails = const AndroidNotificationDetails(
      '2',
      'channelName2',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'icon_no_bg',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('icon_no_bg'),
    );

    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.zonedSchedule(
        id,
        titulo,
        cuerpo,
        tz.TZDateTime.from(hora, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle ,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  Future<void> deleteNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }



}