
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bd.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';


class pantallaHorario extends StatefulWidget {
  const pantallaHorario({Key? key}) : super(key: key);

  @override
  _pantallaHorarioState createState() => _pantallaHorarioState();
}

class _pantallaHorarioState extends State<pantallaHorario> {
  final CalendarController calendarController = CalendarController();
  _SesionDataSource? _dataSource;
  @override
  initState() {
    getSesiones();
    super.initState();
  }
  Future<void> getSesiones()async{
    final horarioBL _bl = horarioBL();
    List<Appointment> sesiones = await _bl.getSesiones();
    setState(() {
      _dataSource = _SesionDataSource(sesiones);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCalendar(
          dataSource: _dataSource,
          showCurrentTimeIndicator: false,
          view: CalendarView.workWeek,
          onTap: calendarTap,
          timeSlotViewSettings: const TimeSlotViewSettings(
            startHour: 8,
            timeIntervalHeight: 30,
            timeIntervalWidth: 50,
            timeInterval: Duration(minutes: 30),
            timeFormat: 'HH:mm',
            timeTextStyle: TextStyle(
              fontSize: 12,
            ),
          ),
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


  void calendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      // Aquí es donde manejas el tap en un evento
      final Appointment appointment = details.appointments?[0];
      // Puedes mostrar un diálogo de confirmación antes de eliminar el evento
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¿Quieres eliminar esta sesión, o todas las repeticiones?'),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Eliminar'),
                onPressed: () {
                  setState(() {
                    // Aquí es donde eliminarías el evento de tu lista de eventos
                    // events.remove(appointment);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (details.targetElement == CalendarElement.calendarCell) {
      print("crear evento");
    }
  }

  void verAsignaturas() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Center(child: Text('Tus asignaturas')),
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
    if (widget.preColor != "") {
      widget.onColorSelected(widget.preColor);
      dropdownValue = widget.preColor;
    } else {
      widget.onColorSelected("Rojo");
    }
    //super.initState();
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
  final firestoreHorarioBD _db = firestoreHorarioBD();
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
          fecha_fin: asignatura['fecha_fin'].toDate(),
          parentDeleteFunc: menosAsignatura,
          parentEditFunc: nuevaAsignatura,
      ));
      asignaturas.add(const SizedBox(height: 10)); // Espacio vertical entre las asignaturas
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
  late final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now().add(Duration(days: 7)));
  void nuevaAsignatura([String? preNombre, String? preColor, String? preUbiClase, String? preUbiLab, String? preId, DateTime? preFechaFin]) {
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
        if (preFechaFin != null) selectedDate.value = preFechaFin;
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
                  }, preColor: color),
                  SizedBox(height: 10),
                  const Text(
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
                  const Text(
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
                  const Text(
                    'Fecha Fin:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: selectedDate,
                    builder: (context, date, child) {
                      return TextButton(
                        onPressed: () {
                        showDatePickerDialog(context,preFechaFin);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(DateFormat('yyyy-MM-dd').format(date)),
                            const Icon(Icons.calendar_today),
                            ],
                        ),
                      );
                    },
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
                      horarioBL().actualizarAsignatura(preId, {
                        'nombre': nombre,
                        'color': color,
                        // Asegúrate de tener una variable color que guarde el color seleccionado en DropdownColor
                        'ubicacion_clase': ubicacionClase,
                        'ubicacion_laboratorio': ubicacionLab,
                        'fecha_fin': selectedDate.value,
                      }).then((value) {
                        menosAsignatura(preId);
                        addAsignaturaLista(
                            nombre, color, ubicacionClase, ubicacionLab, preId,selectedDate.value);
                      }).catchError((error) {
                        print("Error al actualizar asignatura: $error");
                      });

                    }
                    else {
                      // Aquí es donde agregamos la asignatura a Firestore
                      horarioBL().crearAsignatura({
                        'nombre': nombre,
                        'color': color,
                        'ubicacion_clase': ubicacionClase,
                        'ubicacion_laboratorio': ubicacionLab,
                        'usuario': FirebaseAuth.instance.currentUser?.uid,
                        'fecha_fin': selectedDate.value,
                      }).then((id) {
                        addAsignaturaLista(
                            nombre, color, ubicacionClase, ubicacionLab, id,selectedDate.value);
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
  void showDatePickerDialog(BuildContext context, DateTime? preFechaFin) {
    DateTime fecha =selectedDate.value;
    if (preFechaFin != null) fecha = preFechaFin;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            child: SfDateRangePicker(
              initialSelectedDate: fecha,
              view: DateRangePickerView.month,
              monthViewSettings: const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                selectedDate.value = args.value;
                print(selectedDate.value);
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
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
  void addAsignaturaLista(String nombre, String color, String ubicacionClase, String ubicacionLab, String id, DateTime fecha_fin){
    setState(() {
      _asignaturas.add(Asignatura(nombre: nombre, color: color, ubicacion_clase: ubicacionClase, ubicacion_laboratorio: ubicacionLab, id: id,fecha_fin:fecha_fin, parentDeleteFunc: menosAsignatura, parentEditFunc: nuevaAsignatura,));
    });
  }
}




class Asignatura extends StatefulWidget {
  const Asignatura({Key? key, required this.nombre, required this.color, required this.ubicacion_clase, required this.ubicacion_laboratorio, required this.id, required this.parentDeleteFunc, required this.parentEditFunc, required this.fecha_fin}) : super(key: key);
  final String nombre;
  final String color;
  final String ubicacion_clase;
  final String ubicacion_laboratorio;
  final String id;
  final DateTime fecha_fin;
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
                  width: 180,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.nombre,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school, color: Colors.white, size: 20,
                              ), // Icono para la clase
                              SizedBox(width: 5), // Espacio entre el icono y el texto (ubicación de la clase
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.ubicacion_clase,
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              if (widget.ubicacion_laboratorio.isNotEmpty)...[
                                Icon(Icons.science, color: Colors.white, size: 20,), // Icono para la clase
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
                        ],
                      ),
                      SizedBox(width: 15),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.white, size: 20,
                          ), // Icono para la clase
                          SizedBox(width: 5), // Espacio entre el icono y el texto (ubicación de la clase
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              widget.fecha_fin.toString().substring(0,10),
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.parentEditFunc(widget.nombre,widget.color,widget.ubicacion_clase,widget.ubicacion_laboratorio,widget.id,widget.fecha_fin);
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

                    if(await firestoreHorarioBD().eliminarAsignatura(widget.id)){
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

/// An object to set the appointment collection data source to collection, and
/// allows to add, remove or reset the appointment collection.
class _SesionDataSource extends CalendarDataSource {
  _SesionDataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;

  @override
  Widget getAppointmentView(Appointment appointment) {
    print("hola");
    final isLab = appointment.subject == 'Laboratorio'; // Asume que 'subject' contiene el tipo de sesión
    return Container(
      decoration: BoxDecoration(
        color: isLab ? Colors.red : Colors.blue,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Row(
        children: <Widget>[
          Icon(isLab ? Icons.science : Icons.school), // Asume que 'Icons.lab' e 'Icons.class' son los iconos para laboratorio y clase magistral respectivamente
          Text(appointment.location ?? "No hay lugar"), // Asume que 'location' contiene el lugar de la sesión
        ],
      ),
    );
  }
}



