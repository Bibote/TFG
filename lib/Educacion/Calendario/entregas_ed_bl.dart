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
        DateTime hora = (entrega['evento_data']['hora_ini'] as Timestamp).toDate();
        DateTime horafin = (entrega['evento_data']['hora_fin'] as Timestamp).toDate();
        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': entrega['evento_id'],
          'noti_id': entrega['evento_data']['idNoti'],
        };
        entregasCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Entrega "+entrega['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "entrega",
              startTime: hora,
              endTime: horafin,
            )
        );
      });
      asignatura['examenes'].forEach((examen) {
        DateTime hora = (examen['evento_data']['hora_ini'] as Timestamp).toDate();
        DateTime horaFin = (examen['evento_data']['hora_fin'] as Timestamp).toDate();

        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': examen['evento_id'],
          'noti_id': examen['evento_data']['idNoti'],
        };
        examenesCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Examen "+examen['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "examen",
              startTime: hora,
              endTime: horaFin,
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

      asignatura['eventos'].forEach((evento) {
        DateTime hora = (evento['evento_data']['hora_ini'] as Timestamp).toDate();
        DateTime horaFin = (evento['evento_data']['hora_fin'] as Timestamp).toDate();
        Map id = {
          'asignatura_id':asignatura['asignatura_id'] ,
          'evento_id': evento['evento_id'],
          'noti_id': evento['evento_data']['idNoti'],
        };
        eventosCalendario.add(
            Appointment(
              id: id,
              isAllDay: false,
              subject: "Evento "+evento['evento_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              notes: "evento",
              startTime: hora,
              endTime: horaFin,
            )
        );
      });

    }
    listas['entregas'] = entregasCalendario;
    listas['examenes'] = examenesCalendario;
    listas['eventos'] = eventosCalendario;

    return listas;
  }


  Future<Map> crearEvento(asignatura, DateTime hora,DateTime horafin, String nombre, int tipo) async {
    int idNoti = DateTime.now().millisecondsSinceEpoch% (1 << 31);
    String id= await _db.crearEvento(asignatura, hora,horafin, nombre, tipo, idNoti);

    if(id!="") {
      programarNotificacion(idNoti, hora, nombre, tipo);
      return {
        'asignatura_id': asignatura,
        'evento_id': id,
        'noti_id': idNoti,
      };
    } else {
      return {
        'error': 'Error al crear el evento'
      };
    }

  }

  Future<bool> eliminarEvento(Object? id) async {
    if (id is Map) {
      if(await _db.eliminarEvento(id)){
        NotificationManager().deleteNotification(id['noti_id']);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void programarNotificacion(int id,DateTime hora, String nombre, int tipo) async {
    print("Programando notificacion para la hora: $hora");
    try {
    if(tipo== 0){
      NotificationManager().scheduleNotification(id,"Examen en 1 hora", "Tienes examen: $nombre", hora.add(const Duration(hours: -1)));
    }else if(tipo== 1){
      NotificationManager().scheduleNotification(id,"Entrega en 1 hora", "Tienes entrega: $nombre",  hora.add(const Duration(hours: -1)));
    }else {
      NotificationManager().scheduleNotification(id,"Evento en 1 hora", "Tienes evento: $nombre",  hora.add(const Duration(hours: -1)));
    }
    } catch (e) {
      print("Error al programar la notificacion: $e");
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

  Future<Map> crearPlanEstudio(Appointment examen, String diasString) async {
    int? dias = int.tryParse(diasString);
    String nombre = examen.subject.split(" ")[1];
    if(dias==null){
      return {
        'error': 'Asegurese de que el valor introducido es un número'
      };
    }
    Map planEstudio = {
      'tema': nombre,
      'dia_ini': examen.startTime.subtract(Duration(days: dias)),
      'dia_fin': examen.startTime.subtract(const Duration(days: 1)),
    };
    bool resul = await _db.crearPlanEstudioTemas(examen.id, [planEstudio]);
    if(resul){
      return planEstudio;
    } else {
      return {
        'error': 'Error al crear el plan de estudio'
      };
    }
  }

  Future<bool> eliminarPlanEstudio(Object? id) async {
    if (id is Map) {
      return await _db.eliminarPlanEstudio(id);
    } else {
      return Future.value(false);
    }
  }
}