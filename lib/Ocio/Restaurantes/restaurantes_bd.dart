
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class restaurantesBD {
  //singleton
  static final restaurantesBD _instancia = new restaurantesBD._internal();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  factory restaurantesBD() {
    return _instancia;
  }
  restaurantesBD._internal();



  Future<void> restauranteVisto(String id,bool valor) async {
    await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("restaurantes").doc(id).set({
      'like': valor,
    }).then((value) {
      print("Restaurante añadido a favoritos");
    }).catchError((error) {
      print("Error al añadir el restaurante a favoritos: $error");
    });
  }

  Future<List> getRestaurantes() async {
    List<Map> restaurantes = [];
    try {
      var event = await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).collection("restaurantes").get();
      for (var doc in event.docs) {
        var data = doc.data();
        restaurantes.add({
          'id': doc.id,
          'like': data['like'],
        });
      }
      return restaurantes;
    } catch (e) {
      print(e);
      return [];
    }
  }
}