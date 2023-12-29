

import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tfg/Ocio/Grupos/grupos_BD.dart';

class gruposBL {
  static final gruposBL _gruposBL = gruposBL._internal();
  factory gruposBL(){
    return _gruposBL;
  }
  gruposBL._internal();

  Future<Map> crearGrupo(String nombre, String contra, String color) async {
    final random = Random();
    const availableChars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final secreto = List.generate(10, (index) => availableChars[random.nextInt(availableChars.length)]).join();
    return await gruposBD().crearGrupo(nombre, contra, color,secreto);
  }

  Future<List> getGrupos() async {
    return await gruposBD().getGrupos();
  }

  Future<bool> unirseGrupo(String id, String contra) async {
    return await gruposBD().unirseGrupo(id, contra);
  }

  Future<Map> unirseQR(String barcodeScanRes) async {
    List<String> values = barcodeScanRes.split(' ');

    String secret = values[0];
    String id = values[1];
    return await gruposBD().unirseQR(id, secret);
  }

  Future<bool> eliminarGrupo(String id) async {
    return await gruposBD().eliminarGrupo(id);
  }

  Future<List> getPersonas(String idGrupo) async {
    return await gruposBD().getPersonas(idGrupo);
  }

  Future<bool> salirGrupo(String idGrupo, String idPersona) async {
    return await gruposBD().salirGrupo(idGrupo, idPersona);
  }

  Future<bool> modificarGrupo(String preId, String nombre, String contra, String color) async {
    return await gruposBD().modificarGrupo(preId, nombre, contra, color);
  }

  Future<List<PlaceDetails>> getRestaurantes(String idGrupo) async {
    List restaurantes = await gruposBD().getRestaurantes(idGrupo);
    List<PlaceDetails> datosRestaurantes = [];
    //Obtener los datos de los restaurantes
    GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_API']);
    for (var element in restaurantes) {
      await _places.getDetailsByPlaceId(element).then((value) {
        if(value.status == 'OK') {
          datosRestaurantes.add(value.result);
        }
      });
    }
    return datosRestaurantes;
  }


}