import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class EntregaBD {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  static final EntregaBD _singleton = EntregaBD._internal();
  factory EntregaBD() {
    return _singleton;
  }
  EntregaBD._internal();


  Future<String> crearEvento(asignatura, DateTime hora, String nombre, int tipo, int idNoti) {
    return db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(asignatura).collection("eventos").add({
      'hora': Timestamp.fromDate(hora),
      'nombre': nombre,
      'tipo': tipo+1,
      'idNoti': idNoti,
    }).then((value) {
      print("Sesion creada con id: ${value.id}");
      return value.id;
    }).catchError((error) {
      print("Error al crear la sesion: $error");
      return "";
    });
  }

  Future<bool> eliminarEvento(Map id) async {
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(id['asignatura_id']).collection('eventos').doc(id['evento_id']).delete().then((value) {
      print("Sesion eliminada con id: $id");
      return true;
    }).catchError((error) {
      print("Error al eliminar la sesion: $error");
      return false;
    });
    return true;
  }

  Future<List> getEventos() async {
    List<Map> asignaturas = [];
    List<Map> examenes = [];
    List<Map> entregas = [];
    List<Map> eventos = [];
    try {
      var event = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").get();
      for (var element in event.docs) {
        examenes = [];
        entregas = [];
        eventos = [];
        Map asignatura = {
          'asignatura_id' : element.id,
          'asignatura_data' : element.data(),
        };
        var value = await db.collection("usuarios/${FirebaseAuth.instance.currentUser?.uid}/asignaturas/${element.id}/eventos").get();
        for (var evento in value.docs) {
          Map eventoData = {
            'evento_id' : evento.id,
            'evento_data' : evento.data(),
          };
          if(evento.data()['tipo'] == 1) {
            examenes.add(eventoData);
          } else if(evento.data()['tipo'] == 2) {
            entregas.add(eventoData);
          } else {
            eventos.add(eventoData);
          }
        }
        asignatura['examenes'] = examenes;
        asignatura['entregas'] = entregas;
        asignatura['eventos'] = eventos;
        asignaturas.add(asignatura);
      }
    } catch (e) {
      print("Error al obtener las asignaturas: $e");
    }
    return asignaturas;
  }

}