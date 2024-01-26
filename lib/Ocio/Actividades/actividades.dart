import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;


import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tfg/Ocio/Actividades/actividades_bl.dart';

class pantallaActividades extends StatefulWidget {
  @override
  _pantallaActividadesState createState() => _pantallaActividadesState();
}

class _pantallaActividadesState extends State<pantallaActividades> {
  LatLng ubiUsuario = LatLng(0, 0);
  Set<Marker> _markers = {};
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  late BitmapDescriptor iconoAdmin, iconoPublico, iconoApuntado;


  @override
  initState() {
    super.initState();
    conseguirUbicacion();
  }

  @override
  dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> Inicializar() async {
    await conseguirUbicacion();
    await getActividades();
  }

  Future<void> conseguirUbicacion() async {
    // Conseguir la ubicación del usuario
    var permi = await Permission.location.status;
    if (permi.isDenied) {
      await Permission.location.request();
      permi = await Permission.location.status;
    }
    if(permi.isPermanentlyDenied){
      await openAppSettings();
      permi = await Permission.location.status;
    }
    if (permi.isGranted) {
      var ubicacion = await Permission.location.serviceStatus;
      if (!ubicacion.isEnabled) {
        await Permission.location.request();
        ubicacion = await Permission.location.serviceStatus;
      }
      if (ubicacion.isEnabled) {
        var pos = await Permission.location.request();
        if (pos.isGranted) {
          var ubi = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
            ubiUsuario = LatLng(ubi.latitude, ubi.longitude);
        }
      }
    }
  }

  Future<Uint8List?> getBytesFromCanvas(int width, int height, String imagePath) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.transparent;
    final Radius radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    ByteData? data = await rootBundle.load(imagePath);
    Uint8List lst = data.buffer.asUint8List();
    Codec codec = await instantiateImageCodec(lst);
    FrameInfo fi = await codec.getNextFrame();
    paintImage(canvas: canvas, rect: Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), image: fi.image);
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final dataBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return dataBytes?.buffer.asUint8List();
  }


  Future<void> getActividades() async {
    List<Map> grupos = await getGrupos();
    actividadesBL bl = actividadesBL();
    final Uint8List? markerIcon1, markerIcon2, markerIcon3;
    markerIcon1 = await getBytesFromCanvas(125, 225, 'assets/mapAdmin.png');
    if(markerIcon1 != null) {
      iconoAdmin = BitmapDescriptor.fromBytes(markerIcon1);
    } else {
      iconoAdmin = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    markerIcon2 = await getBytesFromCanvas(125, 225, 'assets/mapPublico.png');
    if(markerIcon2 != null) {
      iconoPublico = BitmapDescriptor.fromBytes(markerIcon2);
    } else {
      iconoPublico = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    markerIcon3 = await getBytesFromCanvas(125, 225, 'assets/mapApuntado.png');
    if(markerIcon3 != null) {
      iconoApuntado = BitmapDescriptor.fromBytes(markerIcon3);
    } else {
      iconoApuntado = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
    print("iconos cargados");
    print(iconoAdmin);
    print(iconoPublico);
    print(iconoApuntado);

    await bl.getActividades().then((value) {
      if(value.containsKey('error')) {
        showError("Error", value['error']);
      } else {
        for (var element in value['lista']) {
          if(element['actividad_data']['grupo']!=null){
            //se comprueba que el usuario pertenece al grupo de la actividad
            if(!(grupos.any((grupo) => grupo['grupo_id'] == element['actividad_data']['grupo']))){
              continue;
            }
          }
          if(element['modo'] == 'admin') {
            _markers.add(ActividadAdmin(element['actividad_id'], element['actividad_data']['nombre'], element['actividad_data']['numMax'], element['actividad_data']['hora'].toDate(), LatLng(element['actividad_data']['ubi'].latitude, element['actividad_data']['ubi'].longitude), element['actividad_data']['descripcion'],element['actividad_data']['grupo'],iconoAdmin));
          } else if(element['modo'] == 'ninguno') {
            _markers.add(ActividadPublica(element['actividad_id'], element['actividad_data']['nombre'], element['actividad_data']['numMax'], element['actividad_data']['hora'].toDate(), element['actividad_data']['descripcion'], LatLng(element['actividad_data']['ubi'].latitude, element['actividad_data']['ubi'].longitude),element['actividad_data']['grupo'],iconoPublico));
          } else if(element['modo'] == 'integrante') {
            _markers.add(ActividadApuntado(element['actividad_id'], element['actividad_data']['nombre'], element['actividad_data']['numMax'], element['actividad_data']['hora'].toDate(), LatLng(element['actividad_data']['ubi'].latitude, element['actividad_data']['ubi'].longitude), element['actividad_data']['descripcion'],element['actividad_data']['grupo'],iconoApuntado));
          }
        }
      }
    }).catchError((error) {
      print("ERROR");
      print(error);
      showError('Error', 'Error al obtener las actividades');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Mapa de actividades
        child: FutureBuilder(
          future: Inicializar(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: <Widget> [
                  GoogleMap(
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: ubiUsuario,
                    zoom: 14.4746,
                  ),
                  onTap: (position) {
                    _customInfoWindowController.hideInfoWindow!();
                    onTapMap(position);
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                  onMapCreated: (GoogleMapController controller) async {
                    _customInfoWindowController.googleMapController = controller;
                  },
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: false,
                ),
                  CustomInfoWindow(
                    controller: _customInfoWindowController,
                    height: 150,
                    width: 250,
                    offset: 50,
                  ),
              ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  void onTapMap(LatLng latLng) {
    TextEditingController nombreControler= TextEditingController();
    TextEditingController descripcionControler= TextEditingController();
    TextEditingController maxParticipantesControler= TextEditingController();
    String? idGrupo;
    DateTime hora = DateTime.now();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
              title: Text("Añadir actividad"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nombre"),
                    SizedBox(height: 2.0,),
                    TextField(
                      controller: nombreControler,
                      decoration: InputDecoration(
                        labelText: "Nombre",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),

                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text("Descripción"),
                    SizedBox(height: 2.0,),
                    TextField(
                      controller: descripcionControler,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Text("Número máximo de participantes"),
                    SizedBox(height: 2.0,),
                    TextField(
                      controller: maxParticipantesControler,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0,),
                    Text("Fecha"),
                    SizedBox(height: 2.0,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(DateFormat('yyyy-MM-dd   hh:mm').format(hora)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: hora,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                hora = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  hora.hour,
                                  hora.minute,
                                );
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(hora),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                hora = DateTime(
                                  hora.year,
                                  hora.month,
                                  hora.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0,),
                    const Text("Actividad pública o grupal"),
                    FutureBuilder(
                        future: getGrupos(),
                        builder: (context, snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),),
                              width: double.infinity,
                              height: 15,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }else {
                            return DropdownButton<String>(
                              value: idGrupo,
                              onChanged: (String? newValue) {
                                setState(() {
                                  idGrupo = newValue!;
                                });
                              },
                              items: snapshot.data!.map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value['grupo_id'],
                                  child: Text(value['grupo_data']['nombre']),
                                );
                              }).toList(),
                              icon: idGrupo == null ? Icon(Icons.arrow_downward) : IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  setState(() {
                                    idGrupo = null;
                                  });
                                },
                              ),
                            );
                          }
                        }
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancelar")
                ),
                TextButton(
                  onPressed: () async {
                    print(idGrupo);
                    actividadesBL bl = actividadesBL();
                    Map res = await bl.crearActividad(nombreControler.text, descripcionControler.text, maxParticipantesControler.text, hora,latLng,idGrupo);
                    if(res.containsKey('error')) {
                      showError("Error", res['error']);
                    }else {
                      if(context.mounted)Navigator.of(context).pop();
                      Marker actividad = ActividadAdmin(res['id'], nombreControler.text, int.parse(maxParticipantesControler.text), hora, latLng, descripcionControler.text,idGrupo,iconoAdmin);
                      addActividad(actividad);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Actividad creada correctamente"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text("Añadir")
                ),
              ],
                      );
            }
          );
        }
    );
  }

  void addActividad(Marker actividad) {
    setState(() {
      _markers.add(actividad);
    });
  }


  void showError(String titulo, String cuerpo) {
    showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titulo),
            content: Text(cuerpo),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  Future<Map> getParticipantes(String idActividad) async {
    Map res= {};
    actividadesBL bl = actividadesBL();
    await bl.getParticipantesActividad(idActividad).then((value) {
      if(value.containsKey('error')) {
        showError("Error", value['error']);
        res = {
          'error': value['error'],
        };
      } else {
        res = value;
      }
    }).catchError((error) {
      showError('Error', 'ErroFr al obtener los participantes de la actividad');
      res = {
        'error': 'Error al obtener los participantes de la actividad',
      };
    });
    return res;
  }

  Future<void> verParticipantes(List usuarios) async {
    List userInfo = await actividadesBL().getInfoParticipantes(usuarios);
    if(context.mounted) {
      showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Participantes"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  for(var participante in userInfo)
                    Card(
                      child: ListTile(
                        leading: participante['imagen'] !=null ? CircleAvatar(
                          backgroundImage: NetworkImage(participante['imagen']),
                        ) : const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(participante['nombre']),
                      ),
                    )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      );
    }
  }

  void mostrarDescripcion(String descripcion) {
    showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Descripción"),
            content: SingleChildScrollView(
              child: Text(descripcion),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );

  }

  Marker ActividadPublica(String idActividad, String nombre, int numMax, DateTime hora, descripcion, LatLng ubi,String? idGrupo, BitmapDescriptor iconoPublico) {
    return Marker(
      markerId: MarkerId(idActividad),
      position: ubi,
      consumeTapEvents: true,
      icon: iconoPublico,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
          FutureBuilder(
              future: getParticipantes(idActividad),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),),
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.read_more,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  mostrarDescripcion(descripcion);
                                },
                              ),
                              const SizedBox(width: 8.0,),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.plus_one,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  String? res = await actividadesBL().apuntarseActividad(idActividad, nombre,hora);
                                  if (res=="OK") {
                                    Marker actividad = ActividadApuntado(idActividad,nombre,numMax,hora,ubi,descripcion,idGrupo,iconoApuntado);
                                    setState(() {
                                      MarkerId id = MarkerId(idActividad);
                                      _markers.removeWhere((element) =>
                                      element.markerId == id);
                                      _markers.add(actividad);
                                    });
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Te has apuntado correctamente a la actividad"),
                                          duration: Duration(
                                              seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                  else {
                                    showError("Error", res);
                                  }
                                },
                              ),
                            ],
                          ),
                          if(idGrupo != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FutureBuilder(
                                  future: getNombreGrupo(idGrupo),
                                  builder: (context, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),),
                                        width: double.infinity,
                                        height: 15,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }else {
                                      return Text("Grupo: ${snapshot.data}");
                                    }
                                  }
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd-MM-yyyy hh:mm').format(hora),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.people),
                              const SizedBox(width: 2.0,),
                              Text("${snapshot
                                  .data!['numParticipantes']}/$numMax"),
                              Spacer(),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.people,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  verParticipantes(snapshot.data!['participantes']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
          ),
          ubi,
        );
      },
    );
  }

  Marker ActividadApuntado(String idActividad, String nombre, int numMax, DateTime hora, LatLng ubi, String descripcion, String? idGrupo, BitmapDescriptor iconoApuntado) {
    return Marker(
      markerId: MarkerId(idActividad),
      position: ubi,
      icon: iconoApuntado,
      consumeTapEvents: true,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
          FutureBuilder(
              future: getParticipantes(idActividad),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),),
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.read_more,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  mostrarDescripcion(descripcion);
                                },
                              ),
                              const SizedBox(width: 8.0,),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.exit_to_app,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  bool res = await actividadesBL().salirActividad(idActividad);
                                  if (res) {
                                    Marker actividad = ActividadPublica(idActividad,nombre,numMax,hora,descripcion,ubi,idGrupo,iconoPublico);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Has salido correctamente de la actividad"),
                                          duration: Duration(
                                              seconds: 2),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      MarkerId id = MarkerId(idActividad);
                                      _markers.removeWhere((element) =>
                                      element.markerId == id);
                                      _markers.add(actividad);
                                    });
                                  }else {
                                    showError("Error", "Ha ocurrido un error en el servidor, pruebe de nuevo más tarde");
                                  }
                                },
                              ),
                            ],
                          ),
                          if(idGrupo != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FutureBuilder(
                                  future: getNombreGrupo(idGrupo),
                                  builder: (context, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),),
                                        width: double.infinity,
                                        height: 15,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }else {
                                      return Text("Grupo: ${snapshot.data}");
                                    }
                                  }
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd-MM-yyyy hh:mm').format(hora),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.people),
                              SizedBox(width: 2.0,),
                              Text("${snapshot.data!['numParticipantes']}/$numMax"),
                              const Spacer(),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: Center(
                                      child: const Icon(
                                        Icons.people,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  verParticipantes(
                                      snapshot.data!['participantes']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
          ),
          ubi,
        );
      },
    );
  }

  Marker ActividadAdmin(String idActividad, String nombre, int numMax, DateTime hora, LatLng ubi, String descripcion, String? idGrupo ,BitmapDescriptor icono){
    BitmapDescriptor myIcon =BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);

    return Marker(
      markerId: MarkerId(idActividad),
      position: ubi,
      icon: icono,
      consumeTapEvents: true,
      onTap: () {
        _customInfoWindowController.addInfoWindow!(
          FutureBuilder(
              future: getParticipantes(idActividad),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),),
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.read_more,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  mostrarDescripcion(descripcion);
                                },
                              ),
                              const SizedBox(width: 8.0,),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  bool res = await actividadesBL().eliminarActividad(idActividad);
                                  if (res) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Actividad eliminada correctamente"),
                                          duration: Duration(
                                              seconds: 2),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      MarkerId id = MarkerId(idActividad);
                                      _markers.removeWhere((element) =>
                                      element.markerId == id);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if(idGrupo != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FutureBuilder(
                                  future: getNombreGrupo(idGrupo),
                                  builder: (context, snapshot) {
                                    if(snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),),
                                        width: double.infinity,
                                        height: 15,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }else {
                                      return Text("Grupo: ${snapshot.data}");
                                    }
                                  }
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('dd-MM-yyyy hh:mm').format(hora),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.people),
                              SizedBox(width: 2.0,),
                              Text("${snapshot
                                  .data!['numParticipantes']}/$numMax"),
                              Spacer(),
                              GestureDetector(
                                child: AbsorbPointer(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(
                                          4),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.people,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  verParticipantes(
                                      snapshot.data!['participantes']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
          ),
          ubi,
        );
      },
    );
  }

  Future<List<Map>> getGrupos() async {
    List<Map> grupos = [];
    await actividadesBL().getGrupos().then((value) {
      grupos = value;
    }).catchError((error) {
      throw Exception("Error al obtener los grupos");
    });
    return grupos;
  }

  Future<String> getNombreGrupo(String idGrupo) {
    try {
      return actividadesBL().getNombreGrupo(idGrupo);
    } catch (e) {
      throw Exception("Error al obtener el nombre del grupo");
    }
  }


}

