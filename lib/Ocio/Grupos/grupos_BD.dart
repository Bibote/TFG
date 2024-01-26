
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class gruposBD  {
  //singleton
  static final gruposBD _singleton = gruposBD._internal();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  factory gruposBD(){
    return _singleton;
  }
  gruposBD._internal();

  Future<Map> crearGrupo(String nombre, String contra, String color, String secreto) async {
    Map result = {};
    String idGrupo = "";
    await db.collection('grupos').add({
      'nombre': nombre,
      'color': color,
      'contra': contra,
      'secreto': secreto,
      'admin': FirebaseAuth.instance.currentUser?.uid,
      'integrantes':[FirebaseAuth.instance.currentUser?.uid]
    }).then((value) {
      print("Grupo creada con id: ${value.id}");
      result['idGrupo'] = value.id;
      result['secreto'] = secreto;
      idGrupo=value.id;
    }).catchError((error) {
      print("Error al crear la el grupo: $error");
      result['error'] = error;
    });
    //Se le añade el grupo al usuario
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).update({
      'grupos': FieldValue.arrayUnion([idGrupo]),
    }).catchError((error) {
      print("Error al añadir el grupo al usuario: $error");
      result['error'] = error;
    });

    return result;

  }

  Future<List> getGrupos() async {
    List<Map> grupos = [];
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) async {
      for (var element in value.data()?['grupos']) {
        await db.collection('grupos').doc(element).get().then((
            value) async {
          Map grupo = {
            'grupo_id': value.id,
            'grupo_data': value.data(),
          };
          grupos.add(grupo);
        });
      }
    });
    return grupos;
  }

  Future<Map>unirseGrupo(String id, String contra) async {
    Map result = {};
    await db.collection('grupos').doc(id).get().then((value) async {
      result['idGrupo'] = value.id;
      result['secreto'] = value.data()?['secreto'];
      result['color'] = value.data()?['color'];
      result['nombre'] = value.data()?['nombre'];
      result['admin'] = value.data()?['admin'];
      if (value.data()?['contra'] == contra) {
        //Comprobar que no esta ya en el grupo
        if(value.data()?['integrantes'].contains(FirebaseAuth.instance.currentUser?.uid)){
          result= {'error': 'Ya estás en el grupo'};
          return result;
        }
        await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).update({
          'grupos': FieldValue.arrayUnion([id]),
        }).then((value) async {
          await db.collection('grupos').doc(id).update({
            'integrantes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
          }).catchError((error) {
            print("Error al añadir el usuario al grupo: $error");
            result= {'error': 'Ha ocurrido un error, prueba más tarde'};
          });
        }).catchError((error) {
          print("Error al añadir el grupo al usuario: $error");
          result= {'error': 'Ha ocurrido un error, prueba más tarde'};
        });
      } else {
        print("Contraseña incorrecta");
        result= {'error': 'Id o contraseña incorrectos'};
      }
    }).catchError((error) {
      print("Error al obtener el grupo: $error");
      result= {'error': 'Id o contraseña incorrectos'};
    });
    return result;
  }

  Future<Map> unirseQR(String id, String secret) async {
    Map result = {};
    await db.collection('grupos').doc(id).get().then((value) async {
      result['idGrupo'] = value.id;
      result['secreto'] = value.data()?['secreto'];
      result['color'] = value.data()?['color'];
      result['nombre'] = value.data()?['nombre'];
      result['admin'] = value.data()?['admin'];
      if (value.data()?['secreto'] == secret) {
        if(value.data()?['integrantes'].contains(FirebaseAuth.instance.currentUser?.uid)){
          print("Ya estás en el grupo");
          return false;
        }
        await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).update({
          'grupos': FieldValue.arrayUnion([id]),
        }).then((value) async {
          await db.collection('grupos').doc(id).update({
            'integrantes': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
          }).catchError((error) {
            print("Error al añadir el usuario al grupo: $error");
            return false;
          });
        }).catchError((error) {
          print("Error al añadir el grupo al usuario: $error");
          return false;
        });
      } else {
        result['error'] = "QR incorrecto";
      }
    }).catchError((error) {
      result['error'] = "Error al obtener el grupo";
    });
    return result;
  }

  Future<bool> eliminarGrupo(String id) async {
    //primero hay que eliminar el grupo de cada usuario que pertecezca a el
    await db.collection('grupos').doc(id).get().then((value) async {
      for (var element in value.data()?['integrantes']) {
        await db.collection('usuarios').doc(element).update({
          'grupos': FieldValue.arrayRemove([id]),
        }).catchError((error) {
          print("Error al eliminar el grupo del usuario: $error");
          return false;
        });
      }
    }).catchError((error) {
      print("Error al obtener el grupo: $error");
      return false;
    });

    //hay que eliminar las actividades del grupo
    await db.collection('grupos').doc(id).collection('actividades').where('grupo', isEqualTo: id).get().then((value) async {
      for (var element in value.docs) {
        await db.collection('grupos').doc(id).collection('actividades').doc(element.id).delete().then((value) {
          print("Actividad eliminada con id: ${element.id}");
        }).catchError((error) {
          print("Error al eliminar la actividad: $error");
          return false;
        });
      }
    }).catchError((error) {
      print("Error al obtener las actividades: $error");
      return false;
    });

    //ahora hay que eliminar el grupo
    await db.collection('grupos').doc(id).delete().then((value) {
      print("Grupo eliminado con id: $id");
      return true;
    }).catchError((error) {
      print("Error al eliminar el grupo: $error");
      return false;
    });
    return true;
  }

  Future<List> getPersonas(String idGrupo) async {
    List<Map> personas = [];
    await db.collection('grupos').doc(idGrupo).get().then((value) async {
      for (var element in value.data()?['integrantes']) {
        await db.collection('usuarios').doc(element).get().then((value) {
          Map persona = {
            'persona_idGrupo': element,
            'persona_id' : value.id,
            'persona_data' : value.data(),
          };
          personas.add(persona);
        });
      }
    });
    return personas;
  }

  Future<bool> salirGrupo(String idGrupo, String idPersona) async {
    //Inicializar batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    //Guardar las referencias a los documentos
    DocumentReference userRef = FirebaseFirestore.instance.collection('usuarios').doc(idPersona);
    DocumentReference groupRef = FirebaseFirestore.instance.collection('grupos').doc(idGrupo);

    //Eliminar el grupo del usuario y el usuario del grupo
    batch.update(userRef, {
      'grupos': FieldValue.arrayRemove([idGrupo]),
    });

    batch.update(groupRef, {
      'integrantes': FieldValue.arrayRemove([idPersona]),
    });

    //Ejecutar batch
    return batch.commit().then((value) => true).catchError((error) {
      print("Error al realizar las operaciones en batch: $error");
      return false;
    });
  }

  Future<bool>modificarGrupo(String preId, String nombre, String contra, String color) async {
    await db.collection('grupos').doc(preId).update({
      'nombre': nombre,
      'color': color,
      'contra': contra,
    }).then((value) {
      return true;
    }).catchError((error) {
      return false;
    });
    return true;
  }

  Future<List> getRestaurantes(String idGrupo) async {
    List restaurantes = [];
    await db.collection('grupos').doc(idGrupo).get().then((value) async {
      for (var element in value.data()?['integrantes']) {
        List restaurantePersonal =[];
        await db.collection('usuarios').doc(element).collection("restaurantes").where('like', isEqualTo: true).get().then((value) {
          for (var element in value.docs) {
            restaurantePersonal.add(element.id);
          }
        });
        if(restaurantes.isEmpty) {
          restaurantes = restaurantePersonal;
        }else{
          restaurantes = restaurantes.toSet().intersection(restaurantePersonal.toSet()).toList();
        }
      }
    }).catchError((error) {
      print("Error al obtener los restaurantes: $error");
    });
    return restaurantes;
  }
}