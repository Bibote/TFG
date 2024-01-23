
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tfg/Ocio/Restaurantes/restaurantes_bd.dart';



class restaurantesBL {
  String _nextPageToken = "";
  String api = dotenv.get('GOOGLE_API',fallback:'on ta');
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_API']);

  //LO hacemos singleton
  static final restaurantesBL _instancia = new restaurantesBL._internal();
  factory restaurantesBL() {
    return _instancia;
  }
  restaurantesBL._internal();




  Future<List<PlacesSearchResult>> searchPlaces(String query) async {
    var permisos = Permission.location;
    if (await permisos.isDenied) {
      await permisos.request();
      permisos = Permission.location;
    }
    if (await permisos.isPermanentlyDenied) {
      await openAppSettings();
      permisos = Permission.location;
    }
    if (await permisos.isGranted) {
      Position location = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        final result = await _places.searchNearbyWithRadius(
          Location(lat: location.latitude, lng: location.longitude),
          10000,
          type: "restaurant",
          pagetoken: _nextPageToken,
          keyword: query,
        );
        _nextPageToken = result.nextPageToken ?? "";
        print("resultados");
        print(result.toJson());
        print(result.status == "OK");
        if (result.status == "OK") {
          print("oki");
          var resta = await restaurantesBD().getRestaurantes();
          //Filtrar los que ya estan en la base de datos
          result.results.removeWhere((element) => resta.any((restaurante) => restaurante['id'] == element.placeId));


          return result.results;
        } else {
          print("not oki");
          throw Exception("Error api");
        }
      }
    else {
      print("aqui3");
      throw Exception("permisos");
    }
  }

  List<PlacesSearchResult> testResults = [
    PlacesSearchResult(
      icon: 'https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet.svg',
      name: 'Restaurante de prueba 1',
      //photos: [Photo(/* valores de prueba */)],
      priceLevel: PriceLevel.free,
      rating: 4.1,
      vicinity: 'Vecindad de prueba 1',
      types: ['restaurant', 'food', 'establishment'],
      placeId: 'ID de lugar de prueba 1', reference: 'Referencia de prueba 1',
    ),
    PlacesSearchResult(
      icon: 'URL del icono de prueba 2',
      name: 'Restaurante de prueba 2',
      //photos: [Photo(/* valores de prueba */)],
      priceLevel: PriceLevel.veryExpensive,
      rating: 4.3,
      vicinity: 'Vecindad de prueba 2',
      types: ['restaurant', 'food', 'establishment'],
      placeId: 'ID de lugar de prueba 2', reference: 'Referencia de prueba 2',
    ),
    PlacesSearchResult(
      icon: 'URL del icono de prueba 3',
      name: 'Restaurante de prueba 3',
      //photos: [Photo(/* valores de prueba */)],
      priceLevel: PriceLevel.expensive,
      rating: 4.5,
      vicinity: 'Vecindad de prueba 3',
      types: ['restaurant', 'food', 'establishment'],
      placeId: 'ID de lugar de prueba 3', reference: 'Referencia de prueba 3',
    ),
    PlacesSearchResult(
      icon: 'URL del icono de prueba 4',
      name: 'Restaurante de prueba 4',
     // photos: [Photo(photoReference: ''/* valores de prueba */)],
      priceLevel: PriceLevel.expensive,
      rating: 4.0,
      vicinity: 'Vecindad de prueba 4',
      types: ['restaurant', 'food', 'establishment'],
      placeId: 'ID de lugar de prueba 4', reference: '',
    ),
    PlacesSearchResult(
      icon: 'https://maps.gstatic.com/mapfiles/place_api/icons/v2/restaurant_pinlet.svg',
      name: 'Restaurante de prueba 5',
      //photos: [Photo(photoReference: '', height: null/* valores de prueba */)],
      priceLevel: PriceLevel.inexpensive,
      rating: 3.9,
      vicinity: 'Vecindad de prueba 5',
      types: ['restaurant', 'food', 'establishment'],
      placeId: 'ID de lugar de prueba 5',
      reference: 'Referencia de prueba 5',
    ),
  ];

  Future<List<PlacesSearchResult>> searchPlacesTest(String query) async {
    var resta = await restaurantesBD().getRestaurantes();
    print("impresion de restaurantes");
    print(resta);
    // Simula un retraso para imitar una llamada a la API
    await Future.delayed(Duration(seconds: 1));

    // Mezcla los resultados de prueba
    testResults.shuffle(Random());
    print("impresion de testResults");
    print(testResults);
    // Elimina los elementos de testResults que están en resta
    testResults.removeWhere((testResult) =>
        resta.any((restaurante) => restaurante['id'] == testResult.placeId)
    );

    // Devuelve los datos de prueba
    print("impresion de testResults");
    print(testResults);

    return testResults;
  }


  void restauranteVisto(String string, bool bool) {
    restaurantesBD().restauranteVisto(string, bool);
  }




}