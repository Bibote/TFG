
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bd.dart';


class pantallaHorario extends StatefulWidget {
  const pantallaHorario({Key? key}) : super(key: key);

  @override
  _pantallaHorarioState createState() => _pantallaHorarioState();
}

class _pantallaHorarioState extends State<pantallaHorario> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          showCurrentTimeIndicator: false,
          view: CalendarView.workWeek,
        ),
      ),
      floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            children: [
              SpeedDialChild(
                child: Icon(Icons.add),
                label: 'Añadir asignatura',
                onTap: () => verAsignaturas(),
              ),
              SpeedDialChild(
                child: Icon(Icons.add),
                label: 'Añadir clase',
                onTap: () => verAsignaturas(),
              ),
            ],
      ),
    );
  }

  void verAsignaturas() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Tus asignaturas'),
          content: Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width,
            child: Asignaturas(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrrar'),
            ),
          ],
        );
      },
    );
  }
}
class DropdownColor extends StatefulWidget {
  DropdownColor({required this.onColorSelected, required this.preColor});
  final ValueChanged<String> onColorSelected;
  late final String preColor;
  @override
  _DropdownColorState createState() => _DropdownColorState();
}

class _DropdownColorState extends State<DropdownColor> {
  Map<String, Color> colorMap = {
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Azul': Colors.blue,
    'Amarillo': Colors.yellow,
    'Naranja': Colors.orange,
    'Rosa': Colors.pink,
    'Morado': Colors.purple,
    'Cian': Colors.cyan,
    'Marrón': Colors.brown,
    'Gris': Colors.grey,
    'Lima': Colors.lime,
    'Índigo': Colors.indigo,
  };

  String dropdownValue = 'Rojo';

  @override
  void initState() {
    super.initState();
    if (widget.preColor != "") {
      widget.onColorSelected(widget.preColor);
      dropdownValue = widget.preColor;
    } else {
      widget.onColorSelected("Rojo");

    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.preColor.isNotEmpty) dropdownValue = widget.preColor;
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: TextStyle(color: colorMap[dropdownValue]),
      underline: Container(
        height: 2,
        color: colorMap[dropdownValue],
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          widget.onColorSelected(dropdownValue);
        });
      },
      items: colorMap.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: colorMap[value],
                radius: 10,
              ),
              SizedBox(width: 8),
              Text(value),
            ],
          ),
        );
      }).toList(),
    );
  }
}


class Asignaturas extends StatefulWidget {
  const Asignaturas({Key? key}) : super(key: key);


  @override
  _AsignaturasState createState() => _AsignaturasState();
}
class _AsignaturasState extends State<Asignaturas> {
  final db = FirebaseFirestore.instance;
  List<Widget> _asignaturas = [];
  final FirestoreBD _db = FirestoreBD();
  String error = "";
  Future<List<Widget>> getAsignaturas() async {
    List<Widget> asignaturas = [];
    var asignaturasData = await _db.getAsignaturas();
    for (var asignatura in asignaturasData) {
      asignaturas.add(Asignatura(
          nombre: asignatura['nombre'],
          color: asignatura['color'],
          ubicacion_clase: asignatura['ubicacion_clase'],
          ubicacion_laboratorio: asignatura['ubicacion_laboratorio'],
          id: asignatura['id'],
        parentDeleteFunc: menosAsignatura, 
        parentEditFunc: nuevaAsignatura,
      ));
      asignaturas.add(SizedBox(height: 10)); // Espacio vertical entre las asignaturas
    }
    return asignaturas;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAsignaturas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _asignaturas = snapshot.data!;
          _asignaturas.add(
            GestureDetector(
              onTap: () => nuevaAsignatura(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nueva Asignatura',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          return ListView(
            children: _asignaturas,
          );
        }
      },
    );
  }



  void menosAsignatura(String id) {
    setState(() {
      _asignaturas.removeWhere((element) => element is Asignatura && element.id == id);
    });
  }

  void nuevaAsignatura([String? preNombre, String? preColor, String? preUbiClase, String? preUbiLab, String? preId]) {
    showDialog(
      context: context,
      builder: (_) {
        var nombreController = TextEditingController();
        var ubicacionClaseController = TextEditingController();
        var ubicacionLabController = TextEditingController();
        String color = '';
        String error = "";
        if (preNombre != null) nombreController.text = preNombre;
        if (preUbiClase != null) ubicacionClaseController.text = preUbiClase;
        if (preUbiLab != null) ubicacionLabController.text = preUbiLab;
        if (preColor != null) color = preColor;
        return StatefulBuilder(
          builder: (context, setState) =>
           AlertDialog(
            title: Text('Añadir/Modificar asignatura'),
            content: Container(
              height: MediaQuery.of(context).size.height*0.45,
              width: MediaQuery.of(context).size.width*0.75,
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
                    decoration: InputDecoration(hintText: 'Nombre*'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Color:*',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  DropdownColor(onColorSelected: (String value) {
                    color = value;
                  }, preColor: color),
                  SizedBox(height: 10),
                  Text(
                    'Ubicación clase magistral:*',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  TextFormField(
                    //initialValue: ubicacionClase,
                    controller: ubicacionClaseController,
                    decoration: InputDecoration(hintText: 'Ubicación clase magistral*'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ubicación laboratorio:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  TextFormField(
                    //initialValue: ubicacionLab,
                    controller: ubicacionLabController,
                    decoration: InputDecoration(hintText: 'Ubicación laboratorio'),
                  ),
                  SizedBox(height: 10),
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
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  var nombre = nombreController.text;
                  var ubicacionClase = ubicacionClaseController.text;
                  var ubicacionLab = ubicacionLabController.text;
                  if(nombre.isEmpty || ubicacionClase.isEmpty) {
                    setState(() {
                      error = "Rellena todos los campos obligatorios";
                    });
                  } else {
                    if (preId != null) {
                      FirestoreBD().actualizarAsignatura(preId, {
                        'nombre': nombre,
                        'color': color,
                        // Asegúrate de tener una variable color que guarde el color seleccionado en DropdownColor
                        'ubicacion_clase': ubicacionClase,
                        'ubicacion_laboratorio': ubicacionLab,
                      }).then((value) {
                        menosAsignatura(preId);
                        addAsignaturaLista(
                            nombre, color, ubicacionClase, ubicacionLab, preId);
                      }).catchError((error) {
                        print("Error al actualizar asignatura: $error");
                      });

                    }
                    else {
                      // Aquí es donde agregamos la asignatura a Firestore
                      FirestoreBD().crearAsignatura({
                        'nombre': nombre,
                        'color': color,
                        // Asegúrate de tener una variable color que guarde el color seleccionado en DropdownColor
                        'ubicacion_clase': ubicacionClase,
                        'ubicacion_laboratorio': ubicacionLab,
                        'usuario': FirebaseAuth.instance.currentUser?.uid
                        // Asegúrate de importar FirebaseAuth
                      }).then((id) {
                        addAsignaturaLista(
                            nombre, color, ubicacionClase, ubicacionLab, id);
                      }).catchError((error) {
                        print("Error al agregar asignatura: $error");
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Crear'),
              ),
            ],
          ),
        );
      },
    );
  }
  void addAsignaturaLista(String nombre, String color, String ubicacionClase, String ubicacionLab, String id){
    setState(() {
      _asignaturas.add(Asignatura(nombre: nombre, color: color, ubicacion_clase: ubicacionClase, ubicacion_laboratorio: ubicacionLab, id: id, parentDeleteFunc: menosAsignatura, parentEditFunc: nuevaAsignatura,));
    });
  }
}




class Asignatura extends StatefulWidget {
  const Asignatura({Key? key, required this.nombre, required this.color, required this.ubicacion_clase, required this.ubicacion_laboratorio, required this.id, required this.parentDeleteFunc, required this.parentEditFunc}) : super(key: key);
  final String nombre;
  final String color;
  final String ubicacion_clase;
  final String ubicacion_laboratorio;
  final String id;
  final Function parentDeleteFunc;
  final Function parentEditFunc;
  @override
  _AsignaturaState createState() => _AsignaturaState();
}

class _AsignaturaState extends State<Asignatura> {
  Map<String, Color> colorMap = {
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Azul': Colors.blue,
    'Amarillo': Colors.yellow,
    'Naranja': Colors.orange,
    'Rosa': Colors.pink,
    'Morado': Colors.purple,
    'Cian': Colors.cyan,
    'Marrón': Colors.brown,
    'Gris': Colors.grey,
    'Lima': Colors.lime,
    'Índigo': Colors.indigo,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color: colorMap[widget.color],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
                SizedBox(
                  width: 200,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            widget.nombre,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        Icon(Icons.school, color: Colors.white), // Icono para la clase
                        SizedBox(width: 5), // Espacio entre el icono y el texto (ubicación de la clase
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            widget.ubicacion_clase,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (widget.ubicacion_laboratorio.isNotEmpty)...[
                              Icon(Icons.science, color: Colors.white), // Icono para la clase
                              SizedBox(width: 5),
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.ubicacion_laboratorio,
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                        ],
                      ],
                    ),
                  )
                ),

                Spacer(),
                GestureDetector(
                  onTap: () {
                    // Aquí puedes manejar el evento de edición
                    print('Editar');
                    widget.parentEditFunc(widget.nombre,widget.color,widget.ubicacion_clase,widget.ubicacion_laboratorio,widget.id);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
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
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Borrar'),
                          ),
                        ],
                      ),
                    );

                    if (result == null || !result) {
                      return;
                    }

                    if(await FirestoreBD().eliminarAsignatura(widget.id)){
                      widget.parentDeleteFunc(widget.id);
                    } else {
                      print("Error al eliminar la asignatura");
                    }

                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
        ),
    );
  }

}

