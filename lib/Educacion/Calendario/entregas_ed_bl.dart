import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_edu_db.dart';
import 'package:tfg/resources.dart';
import 'package:timezone/timezone.dart' as tz;

class EntregasBL {

  static final EntregasBL _singleton = EntregasBL._internal();
  static final EntregaBD _db = EntregaBD();
  factory EntregasBL() {
    return _singleton;
  }
  EntregasBL._internal();

  Future<Map> getEventos() async {
    Map listas = {};
    List asignaturasBD = await _db.getEventos();
    List<Appointment> entregasCalendario = [];
    List<Appointment> examenesCalendario = [];
    List<Appointment> eventosCalendario = [];

    for (var asignatura in asignaturasBD) {
      asignatura['entregas'].forEach((entrega) {
        DateTime hora = (entrega['evento_data']['hora'] as Timestamp).toDate();
        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': entrega['evento_id'],
        };
        entregasCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Entrega "+entrega['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "entrega",
              startTime: hora.add(Duration(hours: -1)),
              endTime: hora,
            )
        );
      });
      asignatura['examenes'].forEach((examen) {
        DateTime hora = (examen['evento_data']['hora'] as Timestamp).toDate();
        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': examen['evento_id'],
        };
        examenesCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Examen "+examen['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "examen",
              startTime: hora.add(Duration(hours: -1)),
              endTime: hora,
            )
        );
      });

      asignatura['eventos'].forEach((examen) {
        DateTime hora = (examen['evento_data']['hora'] as Timestamp).toDate();
        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': examen['evento_id'],
        };
        eventosCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Evento "+examen['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "evento",
              startTime: hora.add(Duration(hours: -1)),
              endTime: hora,
            )
        );
      });

    }
    listas['entregas'] = entregasCalendario;
    listas['examenes'] = examenesCalendario;
    listas['eventos'] = eventosCalendario;

    return listas;
  }


  Future<String> crearEvento(asignatura, DateTime hora, String nombre, int tipo) async {
    programarNotificacion(hora, nombre, tipo);

    return await _db.crearEvento(asignatura, hora, nombre, tipo);

  }

  Future<bool> eliminarEvento(Object? id) {
    if (id is Map) {
      return _db.eliminarEvento(id);
    } else {
      return Future.value(false);
    }
  }

  void programarNotificacion(DateTime hora, String nombre, int tipo) async {
    var permiso = await Permission.notification.status;
    if(permiso.isDenied){
      print("pidiendo permiso");
      await Permission.notification.request();
    }
    print(permiso.isDenied);
    print(permiso);
    print("notificacion programada");


    FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
    var androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSInitialize = DarwinInitializationSettings();
    var initSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flnp.initialize(initSettings);

    var androidDetails = const AndroidNotificationDetails(
      'channelId', // El identificador único del canal de notificaciones
      'channelName', // El nombre del canal de notificaciones
      importance: Importance.max, // La importancia de la notificación (alto, medio o bajo)
    );

    var iOSDetails = DarwinNotificationDetails();
    var details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    final scheduledDate = tz.TZDateTime.from(hora, tz.local);


    await flnp.zonedSchedule(
      0,
      'Título de la Notificación',
      'Cuerpo de la Notificación',
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    print("notificacion programada a las: "+scheduledDate.toString());
  }

}