import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class pantallaActividades extends StatefulWidget {
  @override
  _pantallaActividadesState createState() => _pantallaActividadesState();
}

class _pantallaActividadesState extends State<pantallaActividades> {
  LatLng ubiUsuario = LatLng(0, 0);
  Set<Marker> _markers = {};
  CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();


  @override
  initState() {
    super.initState();
    conseguirUbicacion();
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
            _markers.add(
              Marker(
                markerId: MarkerId(ubiUsuario.toString()),
                position: ubiUsuario,
                consumeTapEvents: true,
                onTap: () {
                  print("webos");
                  _customInfoWindowController.addInfoWindow!(
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      height: double.infinity,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Colors.black,
                              size: 30,
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text(
                              "I am here",
                            )
                          ],
                        ),
                      ),
                    ),
                    ubiUsuario,
                  );
                },
              ),
            );

        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Mapa de actividades
        child: FutureBuilder(
          future: conseguirUbicacion(),
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
                  tiltGesturesEnabled: true,
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
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  void onTapMap(LatLng latLng) {
    //Muestra una pantalla para poner nombre y descripcion
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Añadir actividad"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: "Nombre",
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Descripción",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar")
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _markers.add(
                    Marker(
                      markerId: MarkerId(latLng.toString()),
                      position: latLng,
                      consumeTapEvents: true,
                      onTap: () {
                        print("webos");
                        _customInfoWindowController.addInfoWindow!(
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Text(
                                      "I am here",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          latLng,
                        );
                      },
                    ),

                  );
                });
                Navigator.of(context).pop();
              },
              child: Text("Añadir")
            ),
          ],
        )
    );

  }
}
