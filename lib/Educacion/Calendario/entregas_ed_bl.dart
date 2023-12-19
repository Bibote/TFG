import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_edu_db.dart';
import 'package:tfg/notification_manager/notification_manager.dart';
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
    int idNoti = DateTime.now().millisecondsSinceEpoch% (1 << 31);
    String id= await _db.crearEvento(asignatura, hora, nombre, tipo, idNoti);

    if(id!="") {
      programarNotificacion(idNoti, hora, nombre, tipo);
      return id;
    } else {
      return "";
    }

  }

  Future<bool> eliminarEvento(Object? id) {
    if (id is Map) {
      return _db.eliminarEvento(id);
    } else {
      return Future.value(false);
    }
  }

  void programarNotificacion(int id,DateTime hora, String nombre, int tipo) async {
    var permiso = await Permission.notification.status;
    if(permiso.isDenied){
      await Permission.notification.request();
    }

    if(tipo== 0){
      NotificationManager().scheduleNotification(id,"Examen en 1 hora", "Tienes examen: "+nombre, hora.add(Duration(hours: -1)));
    }else if(tipo== 1){
      NotificationManager().scheduleNotification(id,"Entrega en 1 hora", "Tienes entrega "+nombre,  hora.add(Duration(hours: -1)));
    }else {
      NotificationManager().scheduleNotification(id,"Evento en 1 hora", "Tienes evento "+nombre,  hora.add(Duration(hours: -1)));
    }

  }

}