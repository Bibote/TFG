import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tfg/Ocio/Actividades/actividades_bd.dart';

class actividadesBL {

  static final actividadesBL _instancia = actividadesBL._privado();
  static final actividadesBD _db = actividadesBD();
  actividadesBL._privado();
  factory actividadesBL() {
    return _instancia;
  }

  // Crear actividad
  Future<Map> crearActividad(String nombre, String descripcion, String numMax, DateTime hora, LatLng ubi, String? idGrupo) async {
    Map res= {};
    if(nombre == null || descripcion == null || numMax == null || hora == null) {
      return {
        'error': 'Todos los campos son obligatorios',
      };
    }
    //mirar si la hora es posterior a la actual
    if(hora.isBefore(DateTime.now())) {
      return {
        'error': 'La fecha no puede ser anterior a la actual',
      };
    }
    //mirar si el numero maximo es un numero
    int? numMaxInt = int.tryParse(numMax);
    if(numMaxInt == null) {
      return {
        'error': 'El numero maximo debe ser un numero',
      };
    }
    //mirar si el numero maximo es mayor que 0
    if(numMaxInt <= 0) {
      return {
        'error': 'El numero maximo debe ser mayor que 0',
      };
    }
    //Mirar si el nombre tiene mas de 15 caracteres
    if(nombre.length > 15) {
      return {
        'error': 'El nombre no puede tener mas de 15 caracteres',
      };
    }
    //Comprueba si no hay mas de 100 caracteres en la descripcion
    if(descripcion.length > 100) {
      return {
        'error': 'La descripcion no puede tener mas de 100 caracteres',
      };
    }
    if(numMaxInt > 999) {
      return {
        'error': 'El námero máximo de participantes no puede ser mayor que 999',
      };
    }

    Map<String,dynamic> actividad = {
      'nombre': nombre,
      'descripcion': descripcion,
      'numMax': numMaxInt,
      'hora': Timestamp.fromDate(hora),
      'ubi' : GeoPoint(ubi.latitude, ubi.longitude),
    };

    if(idGrupo != null) {
      actividad['grupo'] = idGrupo;
    }

    await _db.crearActividad(actividad).then((value) {
      if(value != "") {
        res = {
          'id': value,
        };
      } else {
        res = {
          'error': 'Error al crear la actividad, pruebe de nuevo, más adelante',
        };
      }
    }).catchError((error) {
      res = {
        'error': 'Error al crear la actividad, pruebe de nuevo, más adelante',
      };
    });
    return res;




  }

  Future<Map> getParticipantesActividad(String idActividad) async {

    try {
      List participantes = await _db.getParticipantesActividad(idActividad);
      return {
        'participantes': participantes,
        'numParticipantes': participantes.length,
      };
    } catch (e) {
      return {
        'error': 'Error al obtener los participantes de la actividad',
      };
    }
  }

  Future<Map> getActividades() async {
    List actividadesBD = [];

    await _db.getActividades().then((value) {
      actividadesBD = value;
    }).catchError((error) {
      return {
        'error': 'Error al obtener las actividades',
      };
    });
    List personas ;
    print(actividadesBD.length);
    print(actividadesBD);
    print("\n");
    for (var actividad in actividadesBD) {
      if(actividad['actividad_data']['participantes'] != null) {
        personas = actividad['actividad_data']['participantes'];
      } else {
        personas = [];
      }
      if(actividad['actividad_data']['creador'] == FirebaseAuth.instance.currentUser?.uid) {
        actividad['modo'] = 'admin';
      } else if(personas.contains(FirebaseAuth.instance.currentUser?.uid)){
        actividad['modo'] = 'integrante';
      } else {
        actividad['modo'] = 'ninguno';
      }
    }
    return {'lista':actividadesBD};

  }

  Future<bool> eliminarActividad(String id) async {
    return await _db.eliminarActividad(id);
  }

  Future<bool> salirActividad(String idActividad) async {
    return await _db.salirActividad(idActividad);
  }

  Future<String> apuntarseActividad(String idActividad, String nombre, DateTime hora) async {
    return await _db.apuntarseActividad(idActividad);
  }

  Future<List> getInfoParticipantes(List usuarios) async {
    return await _db.getInfoParticipantes(usuarios);
  }

  Future<List<Map>> getGrupos() async {
    try {
      return await _db.getGrupos();
    } catch (e) {
      throw Exception('Error al obtener los grupos');
    }
  }

  Future<String> getNombreGrupo(String idGrupo) async {
    try {
      return await _db.getNombreGrupo(idGrupo);
    } catch (e) {
      throw Exception('Error al obtener el nombre del grupo');
    }
  }
}