import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bd.dart';

class horarioBL {

  static final horarioBL _singleton = horarioBL._internal();
  static final firestoreHorarioBD _db = firestoreHorarioBD();
  factory horarioBL() {
    return _singleton;
  }
  horarioBL._internal();



  Future<List<Appointment>> getSesiones() async {
    Map<String, Color> colorMap = {
      'Rojo': Colors.red,
      'Verde': Colors.green,
      'Azul': Colors.blue,
      'Amarillo': Colors.yellow,
      'Naranja': Colors.orange,
      'Rosa': Colors.pink,
      'Morado': Colors.purple,
      'Cian': Colors.cyan,
      'Marrón': Colors.brown,
      'Gris': Colors.grey,
      'Lima': Colors.lime,
      'Índigo': Colors.indigo,
    };
    List asignaturasBD = await _db.getSesiones();
    List<Appointment> sesionesCalendario = [];
    for (var asignatura in asignaturasBD) {
      asignatura['sesiones'].forEach((sesion) {
        DateTime horaIni = (sesion['sesion_data']['hora_ini'] as Timestamp).toDate();
        DateTime horaFin = (sesion['sesion_data']['hora_fin'] as Timestamp).toDate();
        RecurrenceProperties recursion = RecurrenceProperties(
            startDate:  horaIni,
            endDate: (asignatura['asignatura_data']['fecha_fin'] as Timestamp).toDate(),
            recurrenceType: RecurrenceType.daily,
            interval : 7,
            recurrenceRange: RecurrenceRange.endDate,
          );
        String lugar="";
        String tipo="";
        if (sesion['sesion_data']['es_lab']==true){
          tipo= "lab";
          lugar= asignatura['asignatura_data']['ubi_lab'];
        } else {
          tipo= "mag";
          lugar= asignatura['asignatura_data']['ubi_mag'];
        }
        Map id = {
          'asignatura_id': asignatura['asignatura_id'],
          'sesion_id': sesion['sesion_id'],
        };
        sesionesCalendario.add(
            Appointment(
              id: id,
              startTime: horaIni,
              endTime: horaFin,
              isAllDay: false,
              subject: asignatura['asignatura_data']['nombre'],
              color: colorMap[asignatura['asignatura_data']['color']]!,
              location: lugar,
              recurrenceRule: SfCalendar.generateRRule(
                  recursion,
                  horaIni,
                  horaFin
              ),
              notes: tipo,
              recurrenceExceptionDates: sesion['excepciones'],
            )
        );
      });
    }
    return sesionesCalendario;



  }

  Future<bool>actualizarAsignatura(String preId, Map<String, Object> map) async {
    if(await _db.actualizarAsignatura(preId, map)){
      return true;
    } else {
      return false;
    }
  }

  Future<String>crearAsignatura(Map<String, Object?> map) async {
    String id = await _db.crearAsignatura(map);
    if(id != ""){
      return id;
    } else {
      return "";
    }
  }

  Future<List> getAsignaturas() async {
    List asignaturasBD = await _db.getAsignaturas();
    return asignaturasBD;
  }

  Future<Map> crearSesion(asignatura, DateTime startTime, DateTime endTime, bool switchValue) async {
    String id = "";
    if(startTime.isAfter(endTime)){
      return {'error' : 'La hora de inicio no puede ser posterior a la hora de fin'};
    }
    id= await _db.crearSesion(asignatura, startTime, endTime, switchValue);
    if(id != ""){
      return {'id': id};
    } else {
      return {'error' : 'Ha ocurrido un error en el servidor, pruebe de nuevo más tarde'};
    }

  }

  Future<bool> eliminarSesion(Object? id) async {
    if (id is Map) {
      return await _db.eliminarSesion(id);
    } else {
      return false;
    }

  }

  Future<bool>nuevaExcepcion(Object? id, DateTime fecha) {
    if (id is Map) {
      return _db.nuevaExcepcion(id, fecha);
    } else {
      return Future.value(false);
    }
  }

  Future<bool> eliminarAsignatura(String id) async {
    return await _db.eliminarAsignatura(id);
  }
}
