
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class menuBD {
  //hacerlo singleton
  static final menuBD _instancia = new menuBD._internal();
  //Base de datos de fireStore
  static final _db = FirebaseFirestore.instance;
  factory menuBD() {
    return _instancia;
  }
  menuBD._internal();

  Future <String> getNombre() async {
    String nombre = "";
    await _db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      nombre = value.data()?['nombre'];
    });
    return nombre;
  }

  Future<bool> setNombre(String user) async {
   await _db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).update({
      'nombre': user,
    }).catchError((error) {
      print("Failed to update user: $error");
      return false;
    });
    return true;
  }
}