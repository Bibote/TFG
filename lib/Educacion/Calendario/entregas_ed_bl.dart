import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_edu_db.dart';
import 'package:tfg/notification_manager/notification_manager.dart';
import 'package:tfg/resources.dart';

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
              startTime: hora.add(const Duration(hours: -1)),
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
              startTime: hora.add(const Duration(hours: -1)),
              endTime: hora,
            )
        );
        if(examen['plan_estudio']!=null){
          List<Map> planEstudio = [];
          examen['plan_estudio'].forEach((tema) {
            planEstudio.add({
              'tema': tema['tema'],
              'dia_ini': (tema['dia_ini'] as Timestamp).toDate(),
              'dia_fin': (tema['dia_fin'] as Timestamp).toDate(),
            });
          });
          for (var tema in planEstudio) {
            DateTime diaIni = tema['dia_ini'];
            DateTime diaFin = tema['dia_fin'];
            examenesCalendario.add(
                  Appointment(
                    id: id,
                    subject: "Estudiar "+tema['tema'],
                    color: colorMap[asignatura['asignatura_data']['color']]!,
                    notes: "estudio",
                    startTime: diaIni,
                    endTime: diaFin,
                    isAllDay: true,
                  )
              );
          }
        }
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
              startTime: hora.add(const Duration(hours: -1)),
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
      NotificationManager().scheduleNotification(id,"Examen en 1 hora", "Tienes examen: $nombre", hora.add(const Duration(hours: -1)));
    }else if(tipo== 1){
      NotificationManager().scheduleNotification(id,"Entrega en 1 hora", "Tienes entrega: $nombre",  hora.add(const Duration(hours: -1)));
    }else {
      NotificationManager().scheduleNotification(id,"Evento en 1 hora", "Tienes evento: $nombre",  hora.add(const Duration(hours: -1)));
    }

  }

  Future<List<Map>> crearPlanEstudioTemas(Appointment examen, List<TextEditingController> temaControllers, List<TextEditingController> diasControllers) async {
    //Se creará una lista con los temas y los dias de estudio, segun cuantos dias se necesiten por tema
    List<Map> planEstudio = [];
    DateTime diaInicio ;
    DateTime diaFin = examen.endTime.subtract(const Duration(days: 1));
    //se recorrera la lista de fin a inicio para que los temas que se añadan primero esten al final de la lista
    for(int i = temaControllers.length-1; i>=0; i--){
      //Se calcula el dia de inicio de cada tema
      diaInicio = diaFin.subtract(Duration(days: int.parse(diasControllers[i].text)-1));
      //Se añade el tema a la lista
      planEstudio.add({
        'tema': temaControllers[i].text,
        'dia_ini': diaInicio,
        'dia_fin': diaFin,
      });
      //Se actualiza el dia de fin para el siguiente tema
      diaFin = diaInicio.subtract(const Duration(days: 1));
    }
    //Se añade el plan de estudio a la base de datos
    bool resul = await _db.crearPlanEstudioTemas(examen.id, planEstudio);
    if(resul){
      return planEstudio;
    } else {
      return [];
    }
  }
}