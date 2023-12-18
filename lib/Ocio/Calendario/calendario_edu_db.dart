import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EventosBD {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  static final EventosBD _singleton = EventosBD._internal();
  factory EventosBD() {
    return _singleton;
  }
  EventosBD._internal();


  Future<String> crearEvento(asignatura, DateTime hora,DateTime horaFin, String nombre) {
    return db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("eventos").add({
      'hora_ini': Timestamp.fromDate(hora),
      'hora_fin': Timestamp.fromDate(horaFin),
      'nombre': nombre,
    }).then((value) {
      print("Sesion creada con id: ${value.id}");
      return value.id;
    }).catchError((error) {
      print("Error al crear la sesion: $error");
      return "";
    });
  }

  Future<bool> eliminarEvento(String id) async {
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("eventos").doc(id).delete().then((value) {
      print("Sesion eliminada con id: $id");
      return true;
    }).catchError((error) {
      print("Error al eliminar la sesion: $error");
      return false;
    });
    return true;
  }

  Future<List> getEventos() async {
    List<Map> eventos = [];
    try {
      var event = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("eventos").get();
      for (var element in event.docs) {
        Map evento = {
          'evento_id' : element.id,
          'evento_data' : element.data(),
        };
        eventos.add(evento);
      }
    } catch (e) {
      print("Error al obtener las asignaturas: $e");
    }
    return eventos;
  }

}