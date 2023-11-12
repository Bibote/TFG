import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class firestoreHorarioBD {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  static final firestoreHorarioBD _singleton = new firestoreHorarioBD._internal();
  factory firestoreHorarioBD() {
    return _singleton;
  }
  firestoreHorarioBD._internal();

  Future<List<Map<String, dynamic>>> getAsignaturas() async {
    List<Map<String, dynamic>> asignaturas = [];
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").get().then((event) {
      event.docs.forEach((element) {
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
      });
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
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("asignaturas").add({
      'nombre': asignatura['nombre'],
      'color': asignatura['color'],
      'ubi_mag': asignatura['ubicacion_clase'],
      'ubi_lab': asignatura['ubicacion_laboratorio'],
      'usuario': FirebaseAuth.instance.currentUser?.uid,
      'fecha_fin': Timestamp.fromDate(asignatura['fecha_fin']),
    }).then((value) {
      print("Asignatura creada con id: ${value.id}");
      return value.id;
    }).catchError((error) {
      print("Error al crear la asignatura: $error");
    });
    return "";
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

}

