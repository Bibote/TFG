
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
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").add({
      'id': idGrupo,
    }).then((value) {
      print("Grupo añadido al usuario con id: ${value.id}");
    }).catchError((error) {
      print("Error al añadir el grupo al usuario: $error");
      result['error'] = error;
    });

    //Se añade el usuario al grupo
    await db.collection('grupos').doc(idGrupo).collection("usuarios").add({
      'id': FirebaseAuth.instance.currentUser?.uid,
    }).then((value) {
      print("Usuario añadido al grupo con id: ${value.id}");
    }).catchError((error) {
      print("Error al añadir el usuario al grupo: $error");
      result['error'] = error;
    });
    return result;

  }

  Future<List> getGrupos() async {
    List<Map> grupos = [];
    try {
      var event = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").get();
      for (var element in event.docs) {
        await db.collection('grupos').doc(element.data()['id']).get().then((value) async {
          Map grupo = {
            'grupo_id' : value.id,
            'grupo_data' : value.data(),
          };
          grupos.add(grupo);
        });
      }
    } catch (e) {
      print("Error al obtener los grupos: $e");
    }
    print(grupos);
    return grupos;
  }

  Future<bool>unirseGrupo(String id, String contra) async {
    await db.collection('grupos').doc(id).get().then((value) {
      if (value.data()?['contra'] == contra) {
        //Comprobar que no esta ya en el grupo
        db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").get().then((value) {
          for (var element in value.docs) {
            if (element.data()['id'] == id) {
              print("Ya estas en el grupo");
              return false;
            }
          }
        });
        db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").add({
          'id': id,
        }).then((value) {
          db.collection('grupos').doc(id).collection("usuarios").add({
            'id': FirebaseAuth.instance.currentUser?.uid,
          }).then((value) {
            print("Usuario añadido al grupo con id: ${value.id}");
          }).catchError((error) {
            print("Error al añadir el usuario al grupo: $error");
            return false;
          });
          print("Grupo añadido al usuario con id: ${value.id}");
          return true;
        }).catchError((error) {
          print("Error al añadir el grupo al usuario: $error");
          return false;
        });
      } else {
        print("Contraseña incorrecta");
        return false;
      }
    }).catchError((error) {
      print("Error al obtener el grupo: $error");
      return false;
    });
    return true;
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
        //Comprobar que no esta ya en el grupo
        await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").get().then((value) {
          for (var element in value.docs) {
            if (element.data()['id'] == id) {
              result['error'] = "Ya estás en el grupo";
            }
          }
        });
        await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("grupos").add({
          'id': id,
        }).then((value) async {
          await db.collection('grupos').doc(id).collection("usuarios").add({
            'id': FirebaseAuth.instance.currentUser?.uid,
          }).then((value) {
            print("Usuario añadido al grupo con id: ${value.id}");
          }).catchError((error) {
            result['error'] = "Error al añadir el usuario al grupo";
          });
          print("Grupo añadido al usuario con id: ${value.id}");
          return id;
        }).catchError((error) {
          result['error'] = "Error al añadir el grupo al usuario";
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
    await db.collection('grupos').doc(id).collection("usuarios").get().then((value) async {
      for (var element in value.docs) {
        await db.collection('usuarios').doc(element.data()['id']).collection("grupos").where("id",isEqualTo: id).get().then((value){
          for (var element in value.docs) {
            print("sacando");
            print(element.id);
            element.reference.delete();
          }
        });

      }
    }).catchError((error) {
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
    List<Map> listapersonas = await db.collection('grupos').doc(idGrupo).collection("usuarios").get().then((value) {
      List<Map> personas = [];
      for (var element in value.docs) {
        Map persona = {
          'usuario': element.id,
          'usuario_data' : element.data(),
        };
        personas.add(persona);
      }
      return personas;
    });
    List<Map> personas = [];
    for (var element in listapersonas) {
      await db.collection('usuarios').doc(element["usuario_data"]["id"]).get().then((value) {
        Map persona = {
          'persona_idGrupo': element["usuario"],
          'persona_id' : value.id,
          'persona_data' : value.data(),
        };
        personas.add(persona);
      });
    }
    return personas;
  }

  Future<bool> salirGrupo(String idGrupo, String idPersona) async {
    await db.collection('usuarios').doc(idPersona).collection("grupos").where("id",isEqualTo: idGrupo).get().then((value){
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
    await db.collection('grupos').doc(idGrupo).collection("usuarios").where("id",isEqualTo: idPersona).get().then((value){
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
    return true;
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
}