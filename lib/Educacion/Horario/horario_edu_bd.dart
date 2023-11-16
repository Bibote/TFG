import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class firestoreHorarioBD {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  static final firestoreHorarioBD _singleton = firestoreHorarioBD._internal();
  factory firestoreHorarioBD() {
    return _singleton;
  }
  firestoreHorarioBD._internal();

  Future<List<Map<String, dynamic>>> getAsignaturas() async {
    List<Map<String, dynamic>> asignaturas = [];
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").get().then((event) {
      for (var element in event.docs) {
        var asignatura = element.data();
        print("Asignaturabd: ");
        print(asignatura);
        asignaturas.add({
          'id': element.id,
          'nombre': asignatura['nombre'],
          'color': asignatura['color'],
          'ubicacion_clase': asignatura['ubi_mag'],
          'ubicacion_laboratorio': asignatura['ubi_lab'],
          'fecha_fin': asignatura['fecha_fin'],
        });
      }
    });
    return asignaturas;
  }


  Future<bool> eliminarAsignatura(String id) async {
    try {
      await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(id).delete();
      return true;
    } catch (e) {
      print("Error al eliminar la asignatura: $e");
      return false;
    }
  }

  Future<String> crearAsignatura(Map<String, dynamic> asignatura) async {
    print("fecha fin: ${asignatura['fecha_fin']}");
    try {
      DocumentReference docRef = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").add({
        'nombre': asignatura['nombre'],
        'color': asignatura['color'],
        'ubi_mag': asignatura['ubicacion_clase'],
        'ubi_lab': asignatura['ubicacion_laboratorio'],
        'fecha_fin': Timestamp.fromDate(asignatura['fecha_fin']),
      });
      print("Asignatura creada con id: ${docRef.id}");
      return docRef.id;
    } catch (error) {
      print("Error al crear la asignatura: $error");
      return "";
    }
  }


  Future<bool> actualizarAsignatura(String id, Map<String, dynamic> asignatura) async {

    try {
      await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(id).update({
        'nombre': asignatura['nombre'],
        'color': asignatura['color'],
        'ubi_mag': asignatura['ubicacion_clase'],
        'ubi_lab': asignatura['ubicacion_laboratorio'],
        'fecha_fin': Timestamp.fromDate(asignatura['fecha_fin']),
      });
      return true;
    } catch (e) {
      print("Error al actualizar la asignatura: $e");
      return false;
    }
  }
  Future<List> getSesiones() async {
    List<Map> asignaturas = [];
    try {
      var event = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").get();
      for (var element in event.docs) {
        Map asignatura = {
          'asignatura_id' : element.id,
          'asignatura_data' : element.data(),
        };
        var value = await db.collection("usuarios/${FirebaseAuth.instance.currentUser?.uid}/asignaturas/${element.id}/sesiones").get();
        List<Map> sesiones = [];
        for (var sesion in value.docs) {
          Map sesionData = {
            'sesion_id' : sesion.id,
            'sesion_data' : sesion.data(),
          };
          var excepciones = await db.collection("usuarios/${FirebaseAuth.instance.currentUser?.uid}/asignaturas/${element.id}/sesiones/${sesion.id}/excepciones").get();
          List<DateTime> excepcionesList = [];
          for (var excepcion in excepciones.docs) {
            excepcionesList.add((excepcion.data()['fecha'] as Timestamp).toDate());
          }
          sesionData['excepciones'] = excepcionesList;
          sesiones.add(sesionData);
        }
        asignatura['sesiones'] = sesiones;
        asignaturas.add(asignatura);
      }
    } catch (e) {
      print("Error al obtener las asignaturas: $e");
    }
    return asignaturas;
  }

  Future<String> crearSesion(asignatura, DateTime startTime, DateTime endTime, bool switchValue) {
    return db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(asignatura).collection("sesiones").add({
      'hora_ini': Timestamp.fromDate(startTime),
      'hora_fin': Timestamp.fromDate(endTime),
      'es_lab': switchValue,
    }).then((value) {
      print("Sesion creada con id: ${value.id}");
      return value.id;
    }).catchError((error) {
      print("Error al crear la sesion: $error");
      return "";
    });
  }

  Future<bool> eliminarSesion(Map id) async {

    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").doc(id['asignatura_id']).collection('sesiones').doc(id['sesion_id']).delete().then((value) {
      print("Sesion eliminada con id: $id");
      return true;
    }).catchError((error) {
      print("Error al eliminar la sesion: $error");
      return false;
    });
    return true;

  }

  Future<bool> nuevaExcepcion(Map id, DateTime fecha) async {
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("asignaturas").doc(id['asignatura_id']).collection(
        'sesiones').doc(id['sesion_id']).collection('excepciones').add(
        {
          'fecha': Timestamp.fromDate(fecha),
        }
    ).then((value) => true)
        .catchError((error) => false);
    return false;
  }



}

