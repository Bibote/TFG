import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_edu_db.dart';
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

    return await _db.crearEvento(asignatura, hora, nombre, tipo);

  }

  Future<bool> eliminarEvento(Object? id) {
    if (id is Map) {
      return _db.eliminarEvento(id);
    } else {
      return Future.value(false);
    }
  }

  /*
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
    print("id: ");
    print(id);
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

  Future<String> crearSesion(asignatura, DateTime startTime, DateTime endTime, bool switchValue) async {
    if(startTime.isAfter(endTime)){
      return "Fechas incorrectas";
    }
    return await _db.crearSesion(asignatura, startTime, endTime, switchValue);

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
  */

}