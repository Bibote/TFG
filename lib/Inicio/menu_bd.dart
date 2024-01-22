import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class menuBD {
  //hacerlo singleton
  static final menuBD _instancia = new menuBD._internal();
  //Base de datos de fireStore
  static final _db = FirebaseFirestore.instance;
  factory menuBD() {
    return _instancia;
  }
  menuBD._internal();

  Future <Map> getUser() async {
    Map usuario = {};
    await _db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      if(value.exists) {
        usuario = value.data()!;
      }
    });
    return usuario;
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

  Future<String> subirImagen(XFile archivo) async {

    Reference ref = FirebaseStorage.instance.ref().child('perfiles');
    Reference refImagen = ref.child(FirebaseAuth.instance.currentUser!.uid);
    String url = "";

    try {
      await refImagen.putFile(File(archivo.path)).then((value) {
        print("File Uploaded");
      });
      await refImagen.getDownloadURL().then((value) {
        url = value;
        _db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).update({
          'imagen': value,
        }).catchError((error) {
          print("Failed to update user: $error");
          return url;
        });
      });
    } catch (e) {
      return url;
    }
    return url;
  }
}