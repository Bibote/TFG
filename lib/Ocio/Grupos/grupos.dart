
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tfg/Ocio/Grupos/grupos_BL.dart';
import 'package:tfg/main.dart';
import 'package:tfg/resources.dart';


class pantallaGrupos extends StatefulWidget {
  @override
  _pantallaGruposState createState() => _pantallaGruposState();
}
class _pantallaGruposState extends State<pantallaGrupos> {
  final List<tarjetaGrupo> grupos = <tarjetaGrupo>[];


  @override
  void initState() {
    gruposBL().getGrupos().then((value) {
      setState(() {
        for (var element in value) {
          grupos.add(tarjetaGrupo(nombre: element['grupo_data']['nombre'],
            color: element['grupo_data']['color'],
            id: element['grupo_id'],
            esAdmin: element['grupo_data']['admin'] == FirebaseAuth.instance.currentUser?.uid,
            secreto: element['grupo_data']['secreto'],
            borradPadre: menosAsignatura,
            editPadre: crearGrupo,
          ));
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: grupos.length,
          itemBuilder: (BuildContext context, int index) {
            return grupos[index];
          },
          separatorBuilder: (BuildContext context,
              int index) => const Divider(),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Crear grupo',
              onTap: () {
                crearGrupo();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.people),
              label: 'Unirse a un grupo',
              onTap: () {
                unirseGrupo();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.qr_code),
              label: 'Unirse mediante QR',
              onTap: unirseQR,
            ),
          ],
        )
    );
  }

  void crearGrupo([String? preNombre, String? preColor, String? preId]) {
    showDialog(
      context: context,
      builder: (_) {
        var nombreController = TextEditingController();
        var contraController = TextEditingController();
        String color = '';
        String error = "";
        if (preNombre != null) nombreController.text = preNombre;
        if (preColor != null) color = preColor;
        return AlertDialog(
                title: const Text('Añadir/Modificar asignatura'),
                content: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.45,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.75,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Text(
                        'Nombre:*',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(hintText: 'Nombre'),
                      ),
                      const Text(
                        'Contraseñas:*',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      TextFormField(
                        controller: contraController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Contraseña',

                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Color:*',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      DropdownColor(onColorSelected: (String value) {
                        color = value;
                      },
                          preColor: color),
                      const SizedBox(height: 10),
                      Text(
                        error,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (nombreController.text == "" || contraController.text == "") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text("Rellena todos los campos obligatorios"),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }else {
                        //AQUI SE CREA
                        if(preId==null) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator())
                          );
                          Map result = await gruposBL().crearGrupo(
                              nombreController.text, contraController.text,
                              color);
                          Navigator.pop(context);
                          if (result.containsKey('error')) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text(result['error']),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              grupos.add(tarjetaGrupo(
                                nombre: nombreController.text,
                                color: color,
                                id: result['idGrupo'],
                                esAdmin: true,
                                secreto: result['secreto'],
                                borradPadre: menosAsignatura,
                                editPadre: crearGrupo,
                              ));
                            });
                          }
                        }else{
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator())
                          );
                          bool resul = await gruposBL().modificarGrupo(preId, nombreController.text, contraController.text, color);
                          Navigator.pop(context);
                          if(resul){
                            setState(() {
                              grupos.removeWhere((element) => element.id == preId);
                              grupos.add(tarjetaGrupo(
                                nombre: nombreController.text,
                                color: color,
                                id: preId,
                                esAdmin: true,
                                secreto: "",
                                borradPadre: menosAsignatura,
                                editPadre: crearGrupo,
                              ));
                            });
                          }else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Error'),
                                  content: Text("Error al modificar el grupo"),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Crear'),
                  ),

                ],

        );
      },
    );
  }
  void menosAsignatura(String id) {
    setState(() {
      grupos.removeWhere((element) => element.id == id);
    });
  }

  Future<void> unirseQR() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancelar",
      true,
      ScanMode.QR,
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );
    Map resul = await gruposBL().unirseQR(barcodeScanRes);
    Navigator.pop(context);
    if(resul.containsKey('error')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(resul['error']),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }else{
      setState(() {
        setState(() {
          grupos.add(tarjetaGrupo(
            nombre: resul['nombre'],
            color: resul['color'],
            id: resul['idGrupo'],
            esAdmin: resul['admin'] == FirebaseAuth.instance.currentUser?.uid,
            secreto: resul['secreto'],
            borradPadre: menosAsignatura,
            editPadre: crearGrupo,
          ));
        });
      });
    }
  }

  void unirseGrupo() {
    showDialog(
      context: context,
      builder: (_) {
        var idController = TextEditingController();
        var contraController = TextEditingController();
        String error = "";
        return StatefulBuilder(
          builder: (context, setState) =>
              AlertDialog(
                title: const Text('Unirse a un grupo'),
                content: Container(
                  height: MediaQuery
                      .of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const Text(
                        'ID del grupo:*',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      TextFormField(
                        controller: idController,
                        decoration: const InputDecoration(hintText: 'ID'),
                      ),
                      SizedBox(height: 10),
                      const Text(
                        'Contraseña:*',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      TextFormField(
                        controller: contraController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Contraseña',

                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        error,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (idController.text == "" || contraController.text == "") {
                        setState(() {
                          error = "Rellena todos los campos obligatorios";
                        });
                      } else {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator())
                        );
                        bool resul=await gruposBL().unirseGrupo(idController.text, contraController.text);
                        Navigator.pop(context);
                        if (resul) {
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            error = "Id o contraseña incorrectos";
                          });
                        }
                      }
                    },
                    child: const Text('Unirse'),
                  ),
                ],
              ),
        );
      },
    );
  }
}

class tarjetaGrupo extends StatefulWidget {
  const tarjetaGrupo({super.key, required this.nombre, required this.color, required this.id, required this.esAdmin, required this.secreto, required this.borradPadre, required this.editPadre});
  final String nombre;
  final String color;
  final String id;
  final bool esAdmin;
  final String secreto;
  final Function borradPadre;
  final Function editPadre;

  @override
  _tarjetaGrupoState createState() => _tarjetaGrupoState();
}

class _tarjetaGrupoState extends State<tarjetaGrupo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: colorMap[widget.color],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(width: 10),
            Text(
                widget.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )
            ),
            SizedBox(width: 10),
            Spacer(),
            GestureDetector(
              onTap: () {
                showRestaurantes(context, widget.id);
              },
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.fastfood, color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                verPersonas(context, widget.id, widget.esAdmin);
              },
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.people, color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: () {
                showQR(context, widget.id, widget.secreto);
              },
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.qr_code_2, color: Colors.white),
              ),
            ),
            if(widget.esAdmin)...[
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  widget.editPadre(widget.nombre, widget.color, widget.id);
                },
                child: const SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('¿Estás seguro?'),
                      content: const Text('Esta acción no se puede deshacer'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator())
                            );
                            bool resul = await gruposBL().eliminarGrupo(widget.id);
                            Navigator.pop(context);
                            if(resul){
                              widget.borradPadre(widget.id);
                            }
                            Navigator.pop(context, true);
                          },
                          child: const Text('Borrar'),
                        ),
                      ],
                    ),
                  );
                  if (result == null || !result) {
                    return;
                  }
                  //AQUI SE BORRA
                },
                child: Container(
                  width: 30,
                  height: 30,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
            ],
          ],
        ),
      )
    );
  }

  Future<void> showRestaurantes(BuildContext context, String idGrupo) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );
    List<PlaceDetails> restaurantes = await gruposBL().getRestaurantes(idGrupo);
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Restaurantes"),
          content: SizedBox(
            width: 200,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
              children: restaurantes.map((restaurante) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(restaurante.name ?? ""),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              restaurante.priceLevel != null ? getPriceLevel(restaurante.priceLevel!) : 'Sin datos',
                          ),
                          RatingBar.builder(
                            initialRating: restaurante.rating!.toDouble(), // Aquí debes poner la valoración que quieras mostrar
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
                            itemSize: 17,
                            ignoreGestures: true, // Esto hace que la barra de valoración sea solo de lectura
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.map),
                        onPressed: () {
                          verMapa(context, restaurante);
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );

              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
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

  void verMapa(BuildContext context, PlaceDetails restaurante) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.5,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  restaurante.geometry!.location.lat,
                  restaurante.geometry!.location.lng,
                ),
                zoom: 15,
              ),
              markers: Set.from([
                Marker(
                  markerId: MarkerId("restaurante"),
                  position: LatLng(
                    restaurante.geometry!.location.lat,
                    restaurante.geometry!.location.lng,
                  ),
                  infoWindow: InfoWindow(
                    title: restaurante.name,
                    snippet: restaurante.vicinity,
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }




  void showQR(BuildContext context, String groupId, String secret) {
    // Formatea la información del grupo y el secreto como una cadena de texto
    String qrData = secret+" "+groupId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Código QR"),
          content: SizedBox(
            width: 200,
            height: 200,
            child: Center(child: QrImageView(data: qrData)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> verPersonas(BuildContext context, String idGrupo, bool esAdmin) async {
    List personas = await gruposBL().getPersonas(idGrupo);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Personas'),
          content: SingleChildScrollView(
              child: ListBody(
                children: personas.map((persona) {
                  if(esAdmin) {
                    return ListTile(
                      title: Text(persona['persona_data']['nombre']),
                      trailing: persona['persona_id'] == FirebaseAuth.instance.currentUser?.uid ?
                      null
                       :
                      InkWell(
                        onTap: () {
                          salirGrupo(idGrupo, persona['persona_id']);
                        },
                        child: const Icon(Icons.delete),
                      ),
                    );
                  }
                  else{
                    return ListTile(
                      title: Text(persona['persona_data']['nombre']),
                      trailing: persona['persona_id'] == FirebaseAuth.instance.currentUser?.uid ?
                      InkWell(
                        onTap: () {
                          salirGrupo(idGrupo, persona['persona_id']);
                        },
                        child: const Icon(Icons.exit_to_app),
                      )
                          :
                      null
                    );
                  }

                }).toList(),
              )
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> salirGrupo(String idGrupo, String idPersona) async {
    bool resul = await gruposBL().salirGrupo(idGrupo, idPersona);
    if(resul) {
      if (idPersona == FirebaseAuth.instance.currentUser?.uid) {
        widget.borradPadre(idGrupo);
      }
    }
    Navigator.pop(context);
  }

}
