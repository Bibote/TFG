import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:tfg/Ocio/Restaurantes/restaurantes_bl.dart';

class pantallaRestaurantes extends StatefulWidget {
  @override
  _pantallaRestaurantesState createState() => _pantallaRestaurantesState();
}

class _pantallaRestaurantesState extends State<pantallaRestaurantes> {
  var _placesList = <PlacesSearchResult>[];
  var _swipeItems = <SwipeItem>[];
  late MatchEngine matchEngine;

  void conseguirRestaurantes() async {
      try {
        final result = await restaurantesBL().searchPlacesTest("restaurante");
        if(result.isEmpty) throw Exception("No se han encontrado restaurantes");
        setState(() {
          _placesList = result;
          TextStyle estilo = const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          );
          _swipeItems = _placesList.map((e) => SwipeItem(
            likeAction: () {
              print("Like: "+e.placeId.toString());
              restaurantesBL().restauranteVisto(e.placeId.toString(),true);
            },
            nopeAction: () {
              print("Nope: "+e.placeId.toString());
              restaurantesBL().restauranteVisto(e.placeId.toString(),false);
            },
            content: Card(
              child: SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        Placeholder(
                          fallbackHeight: 200,
                          fallbackWidth: 200,),
                        //Image.network("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+e.photos[0].photoReference.toString()+"&key="+dotenv.env['GOOGLE_API']!),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                  e.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  )
                              ),
                            ),
                            const Spacer(),
                            Placeholder(
                              fallbackHeight: 50,
                              fallbackWidth: 50,)
                            //if(e.icon != null) Image.network(e.icon!),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                e.priceLevel != null ? getPriceLevel(e.priceLevel!) : 'Precio no disponible',
                                style: estilo
                            ),
                            RatingBar.builder(
                              initialRating: e.rating!.toDouble(), // Aquí debes poner la valoración que quieras mostrar
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {},
                              ignoreGestures: true, // Esto hace que la barra de valoración sea solo de lectura
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(e.vicinity.toString(),
                          style: estilo,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
                title: const Text("Error"),
                content: const Text("Ha ocurrido un error al cargar los restaurantes"),
                actions: [
                  TextButton(
                    child: const Text("Aceptar"),
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

  String getPriceLevel(PriceLevel priceLevel) {
    switch (priceLevel) {
      case PriceLevel.free:
        return 'Gratis';
      case PriceLevel.inexpensive:
        return '€';
      case PriceLevel.moderate:
        return '€€';
      case PriceLevel.expensive:
        return '€€€';
      case PriceLevel.veryExpensive:
        return '€€€€';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      try {
        conseguirRestaurantes();
      } catch (e) {
        print(e);
        //Mostrar una pantalla diciendo que ha ocurrido un error
        showDialog(context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Ha ocurrido un error al cargar los restaurantes o no quedan restaurantes en su zona"),
                actions: [
                  TextButton(
                    child: const Text("Aceptar"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            }
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwipeCards(
      matchEngine: matchEngine= MatchEngine(swipeItems: _swipeItems),
      onStackFinished: () {
        try {
          conseguirRestaurantes();
        } catch (e) {
          print(e);
          //Mostrar una pantalla diciendo que ha ocurrido un error
          showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Error"),
                  content: const Text("Ha ocurrido un error al cargar los restaurantes o no quedan restaurantes en su zona"),
                  actions: [
                    TextButton(
                      child: const Text("Aceptar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              }
          );
        }
      },
      itemBuilder: (BuildContext context, int index) {
        return Stack(
          children: <Widget>[
            _swipeItems[index].content,
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: InkWell(
                  onTap: () {
                    matchEngine.currentItem?.nope();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 100),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {
                    matchEngine.currentItem?.like();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.green, size: 100),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      likeTag: const Icon(Icons.favorite, color: Colors.green, size: 100),
      nopeTag: const Icon(Icons.close, color: Colors.red, size: 100),
    );
  }


}
