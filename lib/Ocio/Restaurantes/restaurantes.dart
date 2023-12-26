import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:tfg/Ocio/Restaurantes/restaurantes_bl.dart';

class pantallaRestaurantes extends StatefulWidget {
  @override
  _pantallaRestaurantessState createState() => _pantallaRestaurantessState();
}

class _pantallaRestaurantessState extends State<pantallaRestaurantes> {
  final _places = GoogleMapsPlaces(apiKey: "AIzaSyBH9UzFkp4qZrMbnloTZE_OSs4oJgb-RYU");
  var _placesList = <PlacesSearchResult>[];
  var _swipeItems = <SwipeItem>[];
  String _nextPageToken = "";

  Future<List<PlacesSearchResult>> searchPlaces(String query, LatLng location) async {
    print("PAgina");
    print(_nextPageToken);
    final result = await _places.searchNearbyWithRadius(
      Location(lat: location.latitude, lng: location.longitude),
      10000,
      type: "restaurant",
      pagetoken: _nextPageToken,
    );
    _nextPageToken = result.nextPageToken ?? "";
    print(result.toJson());
    if (result.status == "OK") {
      return result.results;
    } else {
      throw Exception(result.errorMessage);
    }
  }

  void conseguirRestaurantes() async {
    var permisos = Permission.location;
    if (await permisos.isDenied) {
      await permisos.request();
    }
    if(await permisos.isPermanentlyDenied){
      await openAppSettings();
    }
    if(await permisos.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      try {
        final result = await searchPlaces("restaurantes", LatLng(position.latitude, position.longitude));
        setState(() {
          _placesList = result;
          _swipeItems = _placesList.map((e) => SwipeItem(
            likeAction: () {
              print("Like: "+e.placeId.toString());
            },
            nopeAction: () {
              print("Nope: "+e.placeId.toString());
            },
            content: Card(
              child: SizedBox.expand(
                child: Container(
                  child: Column(
                    children: [
                      Image.network(e.icon.toString()),
                      Text(e.name),
                      Text(e.types.toString()),
                      Text(e.rating.toString()),
                      Text(e.vicinity.toString()),
                    ],
                  ),
                ),
              ),
            ),
          )).toList();
        });
      } catch (e) {
        print(e);
        //Mostrar una pantalla diciendo que ha ocurrido un error
        showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("Ha ocurrido un error al cargar los restaurantes"),
                actions: [
                  TextButton(
                    child: Text("Aceptar"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    conseguirRestaurantes();
  }

  @override
  Widget build(BuildContext context) {
    return SwipeCards(
        matchEngine: MatchEngine(swipeItems: _swipeItems),
        onStackFinished: () {
          print("Stack finished");
          conseguirRestaurantes();
        },
        itemBuilder: (BuildContext context, int index) {
          return _swipeItems[index].content;
        },
        likeTag: Icon(Icons.favorite, color: Colors.green, size: 100),
        nopeTag: Icon(Icons.close, color: Colors.red, size: 100),
        itemChanged: (item, index) {
          print("Item changed $index");
          print(item);
        },
    );
    /*
    return ListView.builder(
      itemCount: _placesList.length,
      itemBuilder: (context, index) {
        final place = _placesList[index];
        return ListTile(
          title: Text(place.name),
        );
      },
    );;

     */
  }
}