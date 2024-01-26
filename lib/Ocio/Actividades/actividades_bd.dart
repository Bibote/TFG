import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class actividadesBD {

  static final actividadesBD _instancia = actividadesBD._privado();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  actividadesBD._privado();

  factory actividadesBD() {
    return _instancia;
  }

  // Crear actividad
  Future<String> crearActividad(Map<String,dynamic> actividad) {
    actividad['creador'] = FirebaseAuth.instance.currentUser?.uid;
    return db.collection('actividades').add(actividad).then((value) {
      print("Actividad creada con id: ${value.id}");
      return value.id;
    }).catchError((error) {
      print("Error al crear la actividad: $error");
      return "";
    });
  }

  Future<List> getParticipantesActividad(String idActividad) async {
    List participantes = [];
    await db.collection('actividades').doc(idActividad).get().then((value) {
      if(value.data()?['participantes'] != null) {
        participantes = value.data()?['participantes'];
      }
    }).catchError((error) {
      throw Exception('Error al obtener los participantes de la actividad');
    });
    return participantes;
  }

  Future<List> getActividades() {
    List actividades = [];
    //conseguir las actividades que son a partir de la hora actual
    return db.collection('actividades').where('hora', isGreaterThanOrEqualTo: Timestamp.now()).get().then((value) {
      for (var element in value.docs) {
        actividades.add({
          'actividad_id' : element.id,
          'actividad_data' : element.data(),
        });
      }
      return actividades;
    }).catchError((error) {
      throw Exception('Error al obtener las actividades');
    });
  }

  Future<bool> eliminarActividad(String id) async {
    return await db.collection('actividades').doc(id).delete().then((value) {
      print("Actividad eliminada");
      return true;
    }).catchError((error) {
      print("Error al eliminar la actividad: $error");
      return false;
    });
  }

  Future<bool> salirActividad(String idActividad) async {
    return await db.collection('actividades').doc(idActividad).update({
      'participantes': FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.uid])
    }).then((value) {
      print("Usuario eliminado de la actividad");
      return true;
    }).catchError((error) {
      print("Error al eliminar el usuario de la actividad: $error");
      return false;
    });
  }

  Future<String> apuntarseActividad(String idActividad, String nombre, DateTime hora) async {
    List participantes = [];
    bool apuntado = false;
    try {
      var value = await db.collection('actividades').doc(idActividad).get();
      if(value.data()?['participantes'] != null) {
        participantes = value.data()?['participantes'];
      }
      if(participantes.length <= value.data()?['numMax']) {
        try {
          await db.collection('actividades').doc(idActividad).update({
            'participantes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid])
          });
          apuntado = true;

        } catch (error) {
          return "Error al añadir el usuario a la actividad";
        }
      } else {
        return "El grupo está lleno";
      }
    } catch (error) {
      return "Ha ocurrido un error en el servidor, pruebe más adelante";
    }

    crearEventoCalendario(nombre, hora, idActividad);

    if(apuntado) return "OK";
  }

  Future<List> getInfoParticipantes(List docIds) async {
    List participantes = [];
    try {
      List<Future<DocumentSnapshot>> futures = docIds.map((id) => db.collection('usuarios').doc(id).get()).toList();
      List<DocumentSnapshot> documents = await Future.wait(futures);
      for (var document in documents) {
        if (document.exists) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          participantes.add({
            'nombre' : data['nombre'],
            'imagen' : data['imagen'],
          });
        }
      }
      return participantes;
    } catch (error) {
      throw Exception('Error al obtener los participantes de la actividad');
    }
  }

  Future<List<Map>>getGrupos() async {
    List<Map> grupos = [];
    //Se obtienen los grupos a los que pertenece el usuario
    return await db.collection('grupos').where(
        'integrantes', arrayContains: FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      for (var element in value.docs) {
        grupos.add({
          'grupo_id' : element.id,
          'grupo_data' : element.data(),
        });
      }
      return grupos;
    }).catchError((error) {
      throw Exception('Error al obtener los grupos');
    });
  }

  Future<String> getNombreGrupo(String idGrupo) async {
    return await db.collection('grupos').doc(idGrupo).get().then((value) {
      return value.data()?['nombre'];
    }).catchError((error) {
      throw Exception('Error al obtener el nombre del grupo');
    });
  }

  Future<bool> crearEventoCalendario(String nombre, DateTime fecha, String idActividad) async {
    return await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection('eventos').add({
      'nombre': nombre,
      'hora_ini': fecha,
      'hora_fin': fecha.add(Duration(hours: 1)),
      'actividad': idActividad,
    }).then((value) {
      print("Evento creado");
      return true;
    }).catchError((error) {
      print("Error al crear el evento: $error");
      return false;
    });
  }

  Future<bool> eliminarEventoCalendario(String idEvento) async {
    List usuarios = [];
  }
}