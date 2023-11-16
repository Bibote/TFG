
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';


List<Widget> _asignaturas = [];
List<Map> _asignaturasBD = [];

_SesionDataSource? _dataSource;

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

class pantallaHorario extends StatefulWidget {
  const pantallaHorario({Key? key}) : super(key: key);

  @override
  _pantallaHorarioState createState() => _pantallaHorarioState();
}

class _pantallaHorarioState extends State<pantallaHorario> {
  final CalendarController calendarController = CalendarController();



  @override
  initState() {
    getSesiones();
    super.initState();
  }
  Future<void> getSesiones()async{
    final horarioBL bl = horarioBL();
    _asignaturasBD = [];
    var asignaturasData = await bl.getAsignaturas();
    for (var asignatura in asignaturasData) {
      _asignaturasBD.add({
        'nombre': asignatura['nombre'],
        'color': asignatura['color'],
        'ubicacion_clase': asignatura['ubicacion_clase'],
        'ubicacion_laboratorio': asignatura['ubicacion_laboratorio'],
        'id': asignatura['id'],
        'fecha_fin': asignatura['fecha_fin'].toDate(),
      }
      );
    }
    List<Appointment> sesiones = await bl.getSesiones();
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
          controller: calendarController,
          dataSource: _dataSource,
          showCurrentTimeIndicator: false,
          view: CalendarView.workWeek,
          onTap: calendarTap,
          appointmentBuilder: AppointmentBuilder,
          timeSlotViewSettings: const TimeSlotViewSettings(
            //startHour: 8,
            timeIntervalHeight: 60,
            timeIntervalWidth: 100,
            timeInterval: Duration(minutes: 60),
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
                child: const Icon(Icons.add),
                label: 'Añadir asignatura',
                onTap: () => verAsignaturas(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.add),
                label: 'Añadir clase',
                onTap: () => crearSesion(context, DateTime.now()),
              ),
            ],
      ),
    );
  }



  void calendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      // Aquí es donde manejas el tap en un evento
      final Appointment appointment = details.appointments?[0];
      // Puedes mostrar un diálogo con la información del evento y opciones para eliminarlo
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Información del la clase'),
            content: Container(
              height: 100,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Asignatura:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(appointment.subject),
                  const SizedBox(height: 10),
                  const Text("Lugar:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Row(
                    children: [
                      if(appointment.notes=="lab")...[
                        const Icon(Icons.science)
                      ] else ...[
                        const Icon(Icons.school)
                      ],
                      const SizedBox(width: 5),

                      Text(appointment.location?? 'No especificado'),

                    ],
                  ),

                  // Añade aquí más detalles si los necesitas
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Eliminar'),
                onPressed: () async {
                  await horarioBL().nuevaExcepcion(appointment.id,appointment.startTime);
                  if (appointment.recurrenceId != null) {
                    _dataSource?.appointments.remove(appointment);
                    _dataSource?.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[appointment]);
                  }
                  final Appointment? parentAppointment =
                  _dataSource?.getPatternAppointment(appointment, '') as Appointment?;
                  if (parentAppointment != null) {
                    int? index = _dataSource?.appointments.indexOf(parentAppointment);
                    if (index != null && index != -1) {
                      _dataSource?.appointments.removeAt(index);
                      _dataSource?.notifyListeners(CalendarDataSourceAction.remove,
                          <Appointment>[parentAppointment]);
                      parentAppointment.recurrenceExceptionDates != null
                          ? parentAppointment.recurrenceExceptionDates!
                          .add(appointment.startTime)
                          : parentAppointment.recurrenceExceptionDates = <DateTime>[
                        appointment.startTime
                      ];
                      _dataSource?.appointments.add(parentAppointment);
                      _dataSource?.notifyListeners(CalendarDataSourceAction.add,
                          <Appointment>[parentAppointment]);
                    }
                  }
                  Navigator.pop(context);

                },
              ),
              ElevatedButton(
                child: const Text('Eliminar Serie'),
                onPressed: () async {
                  if(await horarioBL().eliminarSesion(appointment.id )) {
                    _dataSource?.appointments.remove(appointment);
                    _dataSource?.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[appointment]);
                  }

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    else if (details.targetElement == CalendarElement.calendarCell) {
      crearSesion(context, details.date!);


    }
  }

  void crearSesion(BuildContext context, DateTime selectedDate) {
    DateTime startTime = selectedDate;
    DateTime endTime = startTime.add(const Duration(hours: 1));
    String? asignaturaSeleccionada = _asignaturasBD[0]['nombre'];
    bool switchValue = false;
    bool tieneLab = true;
    Map asignatura;
    asignatura = _asignaturasBD.firstWhere((asignatura) => asignatura['nombre'] == asignaturaSeleccionada);
    if(asignatura['ubicacion_laboratorio'] == null || asignatura['ubicacion_laboratorio'] == ""){
      tieneLab = false;
      switchValue = false;
    } else {
      tieneLab = true;

    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text('Crear sesión')),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Asignatura:"),
                    DropdownButton<String>(
                      hint: const Text('Selecciona una asignatura'),
                      value: asignaturaSeleccionada,
                      items: _asignaturasBD.map((asignatura) {
                        return DropdownMenuItem<String>(
                          value: asignatura['nombre'],
                          child: Row(
                            children: <Widget>[
                              Text(asignatura['nombre']),
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: colorMap[asignatura['color']], // Asume que 'color' es un string que representa un valor de color en formato ARGB hexadecimal.
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          asignaturaSeleccionada = newValue;
                          asignatura = _asignaturasBD.firstWhere((asignatura) => asignatura['nombre'] == asignaturaSeleccionada);
                          if(asignatura['ubicacion_laboratorio'] == null || asignatura['ubicacion_laboratorio'] == ""){
                            tieneLab = false;
                            switchValue = false;
                          } else {
                            tieneLab = true;

                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("Hora de inicio:"),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(DateFormat('yyyy-MM-dd   hh:mm').format(startTime)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startTime,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                startTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  startTime.hour,
                                  startTime.minute,
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
                              initialTime: TimeOfDay.fromDateTime(startTime),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                startTime = DateTime(
                                  startTime.year,
                                  startTime.month,
                                  startTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Hora fin:"),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(DateFormat('yyyy-MM-dd   hh:mm').format(endTime)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endTime,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                endTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  endTime.hour,
                                  endTime.minute,
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
                              initialTime: TimeOfDay.fromDateTime(endTime),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                endTime = DateTime(
                                  endTime.year,
                                  endTime.month,
                                  endTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Laboratorio o clase magistral:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.school, color: switchValue ? Colors.grey : Colors.green),
                        Switch(
                          value: switchValue,
                          onChanged: tieneLab ? (value) {
                            setState(() {
                              switchValue = value;
                            });
                          } : null,
                        ),
                        Icon(Icons.science, color: switchValue ? Colors.green : Colors.grey),
                      ],
                    ),
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
                ElevatedButton(
                    child: const Text('Crear'),
                    onPressed: () async {
                      Map asignatura = _asignaturasBD.firstWhere((asignatura) => asignatura['nombre'] == asignaturaSeleccionada);
                      String id=await horarioBL().crearSesion(asignatura['id'],startTime,endTime,switchValue);
                      String lugar = switchValue ? asignatura['ubicacion_laboratorio'] : asignatura['ubicacion_clase'];
                      final Appointment app = Appointment(
                        id: {
                          'asignatura_id': asignatura['id'],
                          'sesion_id': id,
                        },
                        startTime: startTime,
                        endTime: endTime,
                        color: colorMap[asignatura['color']]!,
                        subject: asignaturaSeleccionada!,
                        location: lugar,
                        notes: switchValue ? 'lab' : 'mag',
                        recurrenceRule: SfCalendar.generateRRule(
                            RecurrenceProperties(
                              startDate:  DateTime.now(),
                              endDate: asignatura['fecha_fin'],
                              recurrenceType: RecurrenceType.daily,
                              interval : 7,
                              recurrenceRange: RecurrenceRange.endDate,
                            ),
                            startTime,
                            endTime
                        ),
                      );
                      _dataSource!.appointments.add(app);
                      _dataSource!.notifyListeners(
                          CalendarDataSourceAction.add, <Appointment>[app]);
                      Navigator.of(context).pop();
                    }
                ),
              ],
            );
          },
        );
      },
    );
  }



  void verAsignaturas() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Center(child: Text('Tus asignaturas')),
          content: Container(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width,
            child: const Asignaturas(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrrar'),
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

  String dropdownValue = 'Rojo';

  @override
  void initState() {
    if (widget.preColor != "") {
      widget.onColorSelected(widget.preColor);
      dropdownValue = widget.preColor;
    } else {
      widget.onColorSelected("Rojo");
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
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
              const SizedBox(width: 8),
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

  String error = "";
  Future<List<Widget>> getAsignaturas() async {
    List<Widget> asignaturas = [];
    for (var asignatura in _asignaturasBD) {
      asignaturas.add(Asignatura(
        nombre: asignatura['nombre'],
        color: asignatura['color'],
        ubicacion_clase: asignatura['ubicacion_clase'],
        ubicacion_laboratorio: asignatura['ubicacion_laboratorio'],
        id: asignatura['id'],
        fecha_fin: asignatura['fecha_fin'],
        parentDeleteFunc: menosAsignatura,
        parentEditFunc: nuevaAsignatura,
      ));
      asignaturas.add(const SizedBox(height: 10)); // Espacio vertical entre las asignaturas
    }
    return asignaturas;
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAsignaturas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
      _asignaturasBD.removeWhere((element) => element['id'] == id);
    });
  }
  late final ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 7)));
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
            title: const Text('Añadir/Modificar asignatura'),
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
                    decoration: const InputDecoration(hintText: 'Nombre*'),
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
                  }, preColor: color),
                  const SizedBox(height: 10),
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
                    decoration: const InputDecoration(hintText: 'Ubicación clase magistral*'),
                  ),
                  const SizedBox(height: 10),
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
                    decoration: const InputDecoration(hintText: 'Ubicación laboratorio'),
                  ),
                  const SizedBox(height: 10),
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
                child: const Text('Cancelar'),
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
                        _asignaturasBD.add({
                          'nombre': nombre,
                          'color': color,
                          'ubicacion_clase': ubicacionClase,
                          'ubicacion_laboratorio': ubicacionLab,
                          'id': preId,
                          'fecha_fin': selectedDate.value,
                        });
                      }).catchError((error) {
                        print("Error al actualizar asignatura: $error");
                      });

                      _dataSource?.appointments.forEach((element) {
                        if (element.id['asignatura_id'] == preId) {
                          _dataSource?.notifyListeners(CalendarDataSourceAction.remove, <Appointment>[element]);

                          element.color = colorMap[color]!;
                          element.subject = nombre;
                          if(element.notes=="lab") {
                            element.location = ubicacionLab;
                          } else {
                            element.location = ubicacionClase;
                          }
                          element.recurrenceRule = SfCalendar.generateRRule(
                              RecurrenceProperties(
                                startDate:  DateTime.now(),
                                endDate: selectedDate.value,
                                recurrenceType: RecurrenceType.daily,
                                interval : 7,
                                recurrenceRange: RecurrenceRange.endDate,
                              ),
                              element.startTime,
                              element.endTime
                          );

                          _dataSource?.notifyListeners(CalendarDataSourceAction.add, <Appointment>[element]);

                        }
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
                        _asignaturasBD.add({
                          'nombre': nombre,
                          'color': color,
                          'ubicacion_clase': ubicacionClase,
                          'ubicacion_laboratorio': ubicacionLab,
                          'id': id,
                          'fecha_fin': selectedDate.value,
                        });
                      }).catchError((error) {
                        print("Error al agregar asignatura: $error");
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: const Text('Crear'),
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
                Navigator.of(context).pop();
              },
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
                      const SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, color: Colors.white, size: 20,
                              ), // Icono para la clase
                              const SizedBox(width: 5), // Espacio entre el icono y el texto (ubicación de la clase
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.ubicacion_clase,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              if (widget.ubicacion_laboratorio.isNotEmpty)...[
                                const Icon(Icons.science, color: Colors.white, size: 20,), // Icono para la clase
                                const SizedBox(width: 5),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.ubicacion_laboratorio,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.white, size: 20,
                          ), // Icono para la clase
                          const SizedBox(width: 5), // Espacio entre el icono y el texto (ubicación de la clase
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              widget.fecha_fin.toString().substring(0,10),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.parentEditFunc(widget.nombre,widget.color,widget.ubicacion_clase,widget.ubicacion_laboratorio,widget.id,widget.fecha_fin);
                  },
                  child: const SizedBox(
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
                    if(await horarioBL().eliminarAsignatura(widget.id)){
                      widget.parentDeleteFunc(widget.id);
                    } else {
                      print("Error al eliminar la asignatura");
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
        ),
    );
  }
}

Widget AppointmentBuilder(BuildContext context, CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  final isLab = appointment.notes == 'lab';
  return Container(
    decoration: BoxDecoration(
      color: appointment.color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Center(
            child: Text(
              appointment.subject,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Icon(
            isLab ? Icons.science : Icons.school,
            color: Colors.white,
            size: 20,
          ),
          Center(
            child: Text(
                appointment.location ?? "No hay lugar",
                style: const TextStyle(
                  color: Colors.white,
                ),
            ),
          ),

        ],
      ),
    ),
  );
}
/// An object to set the appointment collection data source to collection, and
/// allows to add, remove or reset the appointment collection.
class _SesionDataSource extends CalendarDataSource {
  _SesionDataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;

}



