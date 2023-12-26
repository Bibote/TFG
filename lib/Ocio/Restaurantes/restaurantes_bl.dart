import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;


class restaurantesBL {
  //LO hacemos singleton
  static final restaurantesBL _instancia = new restaurantesBL._internal();
  factory restaurantesBL() {
    return _instancia;
  }
  restaurantesBL._internal();

  Future<List<Map>> getRestaurantes([String? pageToken]) async {
    List<Map> places = [];
    var permisos = Permission.location;
    if (await permisos.isDenied) {
      await permisos.request();
    }
    if(await permisos.isPermanentlyDenied){
      await openAppSettings();
    }
    if(await permisos.isGranted) {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String? apiKey = dotenv.env['GOOGLE_API'];
      String url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position
          .latitude},${position.longitude}&radius=1500&type=restaurant&key=${apiKey}';
      if (pageToken != null) {
        url += '&pagetoken=$pageToken';
      }

      // Realiza la solicitud a la API
      final response = await http.get(Uri.parse(url));

      // Decodifica la respuesta
      final json = jsonDecode(response.body);
      print(json);
      // Crea una lista de lugares a partir de la respuesta
      //List<Map> places = (json['results'] as List).map((item) => Map.fromJson(item)).toList();

      // Comprueba si hay más resultados disponibles
      if (json['next_page_token'] != null) {
        // Espera un poco antes de solicitar la siguiente página para dar tiempo a Google a tenerla lista
        await Future.delayed(Duration(seconds: 2));
        // Solicita la siguiente página de resultados
        final morePlaces = await getRestaurantes(
             json['next_page_token']);
        // Añade los nuevos lugares a la lista
        places.addAll(morePlaces);
      }
      print(places);
    }
    return places;
  }
}