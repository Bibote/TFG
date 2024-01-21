import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    var initializationSettingsAndroid = const AndroidInitializationSettings('icon_no_bg');
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


  Future<void> simpleNotificacitonShow(String titulo, String cuerpo) async {
    //Gestionar permisos
    var permissions = await Permission.notification.status;
    if (permissions.isDenied) {
      await Permission.notification.request();
    }
    //Crear la notificacion
    var androidNotificationDetails = const AndroidNotificationDetails(
      '1',
      'canal',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'icon_no_bg',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('icon_no_bg'),
    );

    var iOSNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iOSNotificationDetails);

    //Enviar la notificacion
    await notificationsPlugin.show(1, titulo, cuerpo, notificationDetails);
  }

  Future<void> scheduleNotification(int id,String titulo, String cuerpo, DateTime hora) async {
    //Gestionar permisos
    var permissions = await Permission.notification.status;
    if (permissions.isDenied) {
      await Permission.notification.request();
    }
    //Gestionar ajustes
    var androidNotificationDetails = const AndroidNotificationDetails(
      '2',
      'canal2',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'icon_no_bg',
      channelShowBadge: true,
      largeIcon: DrawableResourceAndroidBitmap('icon_no_bg'),
    );

    var iOSNotificationDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iOSNotificationDetails);

    //Enviar la notificación
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