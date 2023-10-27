
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


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
                onTap: () => nuevaAsignatura(),
              ),
            ],
      ),
    );
  }

  void verAsignaturas() {
    showDialog(
      context: context,
      builder: (_) {
        var emailController = TextEditingController();
        var messageController = TextEditingController();
        return AlertDialog(
          title: Text('Tus asignaturas'),
          content: Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width,
            child: Asignaturas(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Send them to your email maybe?
                var email = emailController.text;
                var message = messageController.text;
                Navigator.pop(context);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}
class DropdownColor extends StatefulWidget {
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

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
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
          print(dropdownValue);
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
   final List<Widget> _asignaturas = [
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
                   color: Colors.white, // Cambia esto al color que prefieras para el texto
                 ),
               ),
             ],
           ),
         ),
       ),
     )

   ];
   Future getAsignaturas() async {
     //print(FirebaseAuth.instance.currentUser);
     await db.collection('asignatura').where("usuario", isEqualTo: FirebaseAuth.instance.currentUser?.uid).get().then((event)
      {
        event.docs.forEach((element) {
          var asignatura = element.data();
          _asignaturas.insert(0,Asignatura(nombre: asignatura['nombre'], color: asignatura['color'], ubicacion_clase: asignatura['ubi_mag'], ubicacion_laboratorio: asignatura['ubi_lab']));
          _asignaturas.insert(1,SizedBox(height: 10));
        });

      });

   }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAsignaturas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView(
            children: _asignaturas,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
  void nuevaAsignatura() {
    showDialog(
      context: context,
      builder: (_) {
        var emailController = TextEditingController();
        var messageController = TextEditingController();
        return AlertDialog(
          title: Text('Añadir asignatura'),
          content: Container(
            height: MediaQuery.of(context).size.height*0.25,
            width: MediaQuery.of(context).size.width*0.75,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Nombre'),
                ),
                SizedBox(height: 10),
                //Dropdown con colores para elegir
                DropdownColor(),
                SizedBox(height: 10),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(hintText: 'Ubicación clase magistral'),
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(hintText: 'Ubicación laboratorio'),
                ),

              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Send them to your email maybe?
                var email = emailController.text;
                var message = messageController.text;
                Navigator.pop(context);
                //verAsignaturas();
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}

class Asignatura extends StatefulWidget {
  const Asignatura({Key? key, required this.nombre, required this.color, required this.ubicacion_clase, required this.ubicacion_laboratorio}) : super(key: key);
  final String nombre;
  final String color;
  final String ubicacion_clase;
  final String ubicacion_laboratorio;
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
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 5),
                  Text(
                    widget.nombre,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.school, color: Colors.white), // Icono para la clase
                  SizedBox(width: 5),
                  Text(
                    widget.ubicacion_clase,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.science, color: Colors.white), // Icono para el laboratorio
                  SizedBox(width: 5),
                  Text(
                    widget.ubicacion_laboratorio,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Aquí puedes manejar el evento de edición
                      print('Editar');
                    },
                    child: Container(
                      width: 30, // Ajusta esto para cambiar el tamaño del botón
                      height: 30, // Ajusta esto para cambiar el tamaño del botón
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 5), // Espacio entre los botones
                  GestureDetector(
                    onTap: () {
                      // Aquí puedes manejar el evento de eliminación
                      print('Eliminar');
                    },
                    child: Container(
                      width: 30, // Ajusta esto para cambiar el tamaño del botón
                      height: 30, // Ajusta esto para cambiar el tamaño del botón
                      decoration: BoxDecoration(
                        color: Colors.red, // Cambia esto al color que prefieras para el botón
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

