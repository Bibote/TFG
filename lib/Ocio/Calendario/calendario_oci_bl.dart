import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Ocio/Calendario/calendario_edu_db.dart';
import 'package:tfg/notification_manager/notification_manager.dart';


class EventosBL {

  static final EventosBL _singleton = EventosBL._internal();
  static final EventosBD _db = EventosBD();

  factory EventosBL() {
    return _singleton;
  }

  EventosBL._internal();

  Future<List<Appointment>> getEventos() async {
    List eventosBD = await _db.getEventos();
    List<Appointment> eventos = [];
    eventosBD.forEach((evento) {
      DateTime hora = (evento['evento_data']['hora_ini'] as Timestamp).toDate();
      DateTime horaFin = (evento['evento_data']['hora_fin'] as Timestamp)
          .toDate();
      eventos.add(
          Appointment(
            id: evento['evento_id'],
            isAllDay: false,
            subject: evento['evento_data']['nombre'],
            color: Colors.teal,
            notes: "ocio",
            startTime: hora,
            endTime: horaFin,
          )
      );
    });


    return eventos;
  }


  Future<String> crearEvento(asignatura, DateTime hora, DateTime horafin,
      String nombre) async {
    int idNoti = DateTime
        .now()
        .millisecondsSinceEpoch % (1 << 31);
    String id = await _db.crearEvento(asignatura, hora, horafin, nombre);

    if (id != "") {
      NotificationManager().scheduleNotification(
          idNoti, "Evento en 1 hora", "Tienes evento: " + nombre,
          hora.add(Duration(hours: -1)));
      return id;
    } else {
      return "";
    }
  }

  Future<bool> eliminarEvento(Object? id) {
    if (id is String) {
      return _db.eliminarEvento(id);
    } else {
      return Future.value(false);
    }
  }
}
