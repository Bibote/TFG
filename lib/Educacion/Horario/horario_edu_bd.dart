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
    await db.collection('asignatura').where("usuario", isEqualTo: FirebaseAuth.instance.currentUser?.uid).get().then((event) {
      event.docs.forEach((element) {
        var asignatura = element.data();
        print("Asignaturabd: ");
        print(asignatura);
        asignaturas.add({
          'id': element.id,
          'nombre': asignatura['nombre'],
          'color': asignatura['color'],
          'ubicacion_clase': asignatura['ubi_mag'],
          'ubicacion_laboratorio': asignatura['ubi_lab']
        });
      });
    });
    return asignaturas;
  }


  Future<bool> eliminarAsignatura(String id) async {
    try {
      await db.collection('asignatura').doc(id).delete();
      return true;
    } catch (e) {
      print("Error al eliminar la asignatura: $e");
      return false;
    }
  }

  Future<String> crearAsignatura(Map<String, dynamic> asignatura) async {
    await db.collection('asignatura').add({
      'nombre': asignatura['nombre'],
      'color': asignatura['color'],
      'ubi_mag': asignatura['ubicacion_clase'],
      'ubi_lab': asignatura['ubicacion_laboratorio'],
      'usuario': FirebaseAuth.instance.currentUser?.uid // Asegúrate de importar FirebaseAuth
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
      await db.collection('asignatura').doc(id).update({
        'nombre': asignatura['nombre'],
        'color': asignatura['color'],
        'ubi_mag': asignatura['ubicacion_clase'],
        'ubi_lab': asignatura['ubicacion_laboratorio'],
      });
      return true;
    } catch (e) {
      print("Error al actualizar la asignatura: $e");
      return false;
    }
  }
  Future<List> getSesiones() async {
    var snapShotsValue = await db
        .collection("clase").where("usuario", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    List<Map> sesiones = [];
    for (var element in snapShotsValue.docs) {
      var asignaturaRef = db.doc(element.data()['asignatura'].path);
      var snapShotAsignatura = await asignaturaRef.get();
      Map sesion = {
        'id': element.id,
        'data': element.data(),
        'asignatura': snapShotAsignatura.data(),
      };
      sesiones.add(sesion);
    }
    print("sesionesBD:");
    print(sesiones);
    return sesiones;
  }
}

