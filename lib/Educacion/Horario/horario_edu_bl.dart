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
    List sesionesBD = await _db.getSesiones();
    List<Appointment> sesionesCalendario = [];
    sesionesBD.forEach((sesion) {
      String lugar= "";
      if (sesion['data']['esMag']==true){
        lugar= sesion['asignatura']['ubi_mag'];
      } else {
        lugar= sesion['asignatura']['ubi_lab'];
      }
      sesionesCalendario.add(
          Appointment(
            startTime: (sesion['data']['hora_ini'] as Timestamp).toDate(),
            endTime: (sesion['data']['hora_fin'] as Timestamp).toDate(),
            isAllDay: false,
            subject: sesion['asignatura']['nombre'],
            color: colorMap[sesion['asignatura']['color']]!,
            location: lugar,
          )
      );
    });
    return sesionesCalendario;
  }
}
