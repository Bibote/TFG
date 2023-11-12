import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bd.dart';

class horarioBL {

  static final horarioBL _singleton = new horarioBL._internal();
  static final firestoreHorarioBD _db = new firestoreHorarioBD();
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
    asignaturasBD.forEach((asignatura) {
      String ubiMag= asignatura['asignatura_data']['ubi_mag'];
      String ubiLab= "";
      if(asignatura['asignatura_data']['ubi_mag'] != null){
        ubiMag = asignatura['asignatura_data']['ubi_lab'];
      }
      RecurrenceProperties recursion = RecurrenceProperties(
                                        startDate:  DateTime.now(),
                                        endDate: (asignatura['asignatura_data']['fecha_fin'] as Timestamp).toDate(),
                                        recurrenceType: RecurrenceType.daily,
                                        interval : 7,
                                        recurrenceRange: RecurrenceRange.endDate,
                                        //recurrenceCount: 20,
                                      );
      asignatura['sesiones'].forEach((sesion) {
        DateTime horaIni = (sesion['sesion_data']['hora_ini'] as Timestamp).toDate();
        DateTime horaFin = (sesion['sesion_data']['hora_fin'] as Timestamp).toDate();
        String lugar="";
        if (asignatura['asignatura_data']['es_lab']==true){
          lugar= ubiLab;
        } else {
          lugar= ubiMag;
        }
        sesionesCalendario.add(
            Appointment(
              id: sesion['id'],
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
              //recurrenceExceptionDates: sesion['asignatura']['excepciones'],
            )
        );
      });
    });
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
    print("map: ");
    print(map);
    String id = await _db.crearAsignatura(map);
    if(id != ""){
      return id;
    } else {
      return "";
    }
  }
}
