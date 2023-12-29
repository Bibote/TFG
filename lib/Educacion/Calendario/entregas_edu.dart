import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_ed_bl.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';
import 'package:tfg/resources.dart';



_EntregasDataSource? _dataSource;
List<Map> _asignaturasBD = [];
List<Appointment> _entregas = [];
List<Appointment> _examenes = [];
List<Appointment> _eventos = [];

class EntregasPage extends StatefulWidget {
  const EntregasPage({Key? key}) : super(key: key);

  @override
  _EntregasPageState createState() => _EntregasPageState();
}

class _EntregasPageState extends State<EntregasPage> {
  bool entregasChecked = true;
  bool examenesChecked = true;
  bool eventosChecked = true;
  List selecionados = [];

  final CalendarController calendarController = CalendarController();



  @override
  initState() {
    getAsignaturas();
    getEventos();
    super.initState();
  }
  Future<void> getEventos() async {
    final EntregasBL bl = EntregasBL();
    Map sesiones = await bl.getEventos();
    setState(() {
      _entregas = sesiones['entregas'];
      _examenes = sesiones['examenes'];
      _eventos = sesiones['eventos'];
    });
  }

  Future<void> getAsignaturas() async {
    final horarioBL blHorario = horarioBL();
    _asignaturasBD = [];
    var asignaturasData = await blHorario.getAsignaturas();
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
  }

  void filtrar() {
    List<Appointment> entregas = [];
    List<Appointment> examenes = [];
    List<Appointment> eventos = [];
    if(entregasChecked) {
      entregas = _entregas;
    }
    if(examenesChecked) {
      examenes = _examenes;
    }
    if(eventosChecked) {
      eventos = _eventos;
    }
    setState(() {
      _dataSource = _EntregasDataSource([...entregas,...examenes,...eventos]);
    });
  }



  @override
  Widget build(BuildContext context) {
    filtrar();
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Entregas"),
                  Checkbox(
                      value: entregasChecked,
                      onChanged: (value) {
                        setState(() {
                          entregasChecked = value!;
                          filtrar();
                        });
                      }
                  ),
                  Text("Examenes"),
                  Checkbox(
                      value: examenesChecked,
                      onChanged: (value) {
                        setState(() {
                          examenesChecked = value!;
                          filtrar();
                        });
                      }
                  ),
                  Text("Eventos"),
                  Checkbox(
                      value: eventosChecked,
                      onChanged: (value) {
                        setState(() {
                          eventosChecked = value!;
                          filtrar();
                        });
                      }
                  ),
                ],
              ),
              Expanded(
                child: SfCalendar(
                  dataSource: _dataSource,
                  firstDayOfWeek: 1,
                  view: CalendarView.month,
                  onTap: calendarTap,
                  allowedViews: [
                    CalendarView.week,
                    CalendarView.month,
                  ],
                  monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                      showAgenda: true,
                  ),
                  ),
              ),
            ],
          ),
        ),
    );
  }

  void calendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final Appointment evento = details.appointments?[0];
      if(evento.notes == "examen") {
        print("examen");
        crearPlanEstudio(context, evento);
      } else if(evento.notes == "entrega") {
        print("entrega");
        borrarEvento(context, evento);
      } else if(evento.notes == "evento") {
        print("evento");
        borrarEvento(context, evento);
      }

    }
    else if (details.targetElement == CalendarElement.calendarCell) {
      print("calendarCell");
      crearSesion(context, details.date!);
    }
  }

  void borrarEvento(BuildContext context, Appointment evento) {
    showDialog(
      context: context, // Asegúrate de tener el contexto disponible aquí
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres borrar este evento?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Eliminar evento'),
              onPressed: () async {
                if(await EntregasBL().eliminarEvento(evento.id )) {
                  _dataSource?.appointments.remove(evento);
                  _dataSource?.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[evento]);
                  setState(() {
                    if(evento.notes == "examen") {
                      _examenes.remove(evento);
                    } else if(evento.notes == "entrega") {
                      _entregas.remove(evento);
                    } else if(evento.notes == "evento") {
                      _eventos.remove(evento);
                    }
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void crearPlanEstudio(BuildContext context, Appointment examen){
    final List<bool> tipo = <bool>[true, false];
    final List<Widget> temas = [];
    final List<TextEditingController> temaControllers = [];
    final List<TextEditingController> diasControllers = [];
    TextEditingController diasGeneral= TextEditingController();
    int idTema = 0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text('Crear plan de estudio')),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  children: <Widget>[
                    //Switch para elegir si es por temas o en general
                    const Text("Tipo de plan de estudio:"),
                    Center(
                      child: ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < tipo.length; i++) {
                              tipo[i] = i == index;
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        constraints: const BoxConstraints(minWidth: 70,minHeight: 30),
                        isSelected: tipo,
                        children: const <Widget>[
                          Text("Por temas"),
                          Text("General"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                        child: tipo[0] ? Column(
                          children: [
                            ...temas,
                            ElevatedButton(
                              child: const Text('Añadir tema'),
                              onPressed: () {
                                int currentId = idTema;
                                final temaController = TextEditingController();
                                final diasController = TextEditingController();
                                temaControllers.add(temaController);
                                diasControllers.add(diasController);
                                setState(() {
                                  temas.add(
                                      Row(
                                        key: Key('$currentId'),
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: temaController,
                                              decoration: const InputDecoration(
                                                hintText: 'Nombre del tema',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              controller: diasController,
                                              decoration: const InputDecoration(
                                                hintText: 'Días por tema',
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                temas.removeWhere((widget) => widget.key == Key('$currentId'));
                                                temaControllers.removeAt(currentId);
                                                diasControllers.removeAt(currentId);
                                              });
                                            },
                                            child: const Icon(Icons.delete),
                                          ),
                                        ],
                                      )
                                  );
                                  idTema++;
                                });
                              },
                            ),
                          ],
                        ) : Column(
                          children: [
                            const Text("Días de estudio:"),
                            TextField(
                              controller: diasGeneral,
                              decoration: const InputDecoration(
                                hintText: 'Introduza los días que quiere dedicar al estudio',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        )
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

                      String idAsignatura ="";
                      String idExamen ="";
                      if(examen.id is Map) {
                        idAsignatura = (examen.id as Map)?['asignatura_id'];
                        idExamen = (examen.id as Map)?['evento_id'];
                      }

                      bool existe = _examenes.any((app) {
                        if (app.id is Map<String, dynamic>) {
                          var idMap = app.id as Map<String, dynamic>;
                          return idMap['sesion_id'] == idExamen && app.notes == "estudio";
                        }
                        return false;
                      });


                      if (existe) {
                        print("Existe");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmación'),
                              content: Text('Ya existe una sesión de estudio para este examen. ¿Quieres borrar la anterior?'),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text('Cancelar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ElevatedButton(
                                  child: Text('Borrar'),
                                  onPressed: () {
                                    List<Appointment> removedAppointments = [];

                                    _examenes.removeWhere((app) {
                                      if (app.id is Map<String, dynamic>) {
                                        var idMap = app.id as Map<String, dynamic>;
                                        if (idMap['sesion_id'] == idExamen && app.notes == "estudio") {
                                          removedAppointments.add(app);
                                          return true;
                                        }
                                      }
                                      return false;
                                    });

                                    _dataSource?.appointments.removeWhere((app) {
                                      if (app.id is Map<String, dynamic>) {
                                        var idMap = app.id as Map<String, dynamic>;
                                        return idMap['sesion_id'] == idExamen && app.notes == "estudio";
                                      }
                                      return false;
                                    });

                                    _dataSource?.notifyListeners(CalendarDataSourceAction.remove, removedAppointments);

                                    guardarPlan(true, examen, temaControllers, diasControllers, diasGeneral);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),

                              ],
                            );
                          },
                        );

                      } else {
                        print("No existe");
                        guardarPlan(true, examen, temaControllers, diasControllers, diasGeneral);
                        Navigator.of(context).pop();
                      }


                    }
                ),
                ElevatedButton(
                    child: const Text('Borrar examen'),
                    onPressed: () {
                      borrarEvento(context, examen);
                    }
                ),
              ],
            );
          },
        );
      },
    );
  }
  void guardarPlan(bool temas, Appointment examen, List<TextEditingController> temaControllers, List<TextEditingController> diasControllers, TextEditingController diasGeneral) async {
    if(temas) {
      if(temaControllers.isEmpty) {
        showError("Error", 'Debe haber al menos un tema');
      }
      for (int i = 0; i < temaControllers.length; i++) {
        if(temaControllers[i].text == "" || diasControllers[i].text == "") {
          //Pop up de error
          showError("Error", 'No puede haber campos vacíos');
        }
      }
    } else {
      if(diasGeneral.text == "") {
        showError("Error", 'No puede haber campos vacíos');
      }
    }
    String idAsignatura ="";
    String idExamen ="";
    if(examen.id is Map) {
      idAsignatura = (examen.id as Map)?['asignatura_id'];
      idExamen = (examen.id as Map)?['evento_id'];
    }
    //Ahora crear plan de estudio
    if (temas) {
      List plan = await EntregasBL().crearPlanEstudioTemas(examen, temaControllers, diasControllers);
      if (plan.isNotEmpty) {
        //Se añade al calendario empezando por el final y calculando las fechas
        for(int i = plan.length-1; i>=0; i--){
          final Appointment app = Appointment(
            id: {
              'asignatura_id': idAsignatura,
              'sesion_id': idExamen,
            },
            startTime: plan[i]['dia_ini'],
            endTime: plan[i]['dia_fin'],
            isAllDay: true,
            color: colorMap[_asignaturasBD.firstWhere((asignatura) => asignatura['id'] == idAsignatura)['color']]!,
            subject: plan[i]['tema'],
            notes: "estudio",
          );

          //Ahora se añade al calendario
          _examenes.add(app);
          _dataSource!.appointments.add(app);
          _dataSource!.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);

        }


      } else {
        showError("Error", 'Error al crear el plan de estudio');
      }
    } else {
      print('Días: ${diasGeneral.text}');
    }
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




  void crearSesion(BuildContext context, DateTime selectedDate) {
    final List<bool> tipo = <bool>[true, false, false];
    DateTime hora = selectedDate.add(const Duration(hours: 12));
    String? asignaturaSeleccionada = _asignaturasBD[0]['nombre'];
    TextEditingController _nombreController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text('Crear evento')),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  children: <Widget>[
                    Center(
                      child: ToggleButtons(
                        onPressed: (int index) {
                          setState(() {
                            // The button that is tapped is set to true, and the others to false.
                            for (int i = 0; i < tipo.length; i++) {
                              tipo[i] = i == index;
                            }
                          });
                        },
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        constraints: const BoxConstraints(minWidth: 70,minHeight: 30),
                        isSelected: tipo,
                        children: const <Widget>[
                          Text("Examen"),
                          Text("Entrega"),
                          Text("Evento"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        });
                      },
                    ),
                    const Text("Nombre"),
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Hora:"),
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
                      String tipoA = "";
                      String id=await EntregasBL().crearEvento(asignatura['id'],hora, _nombreController.text, tipo.indexOf(true));
                      if(tipo.indexOf(true) == 0) {
                        tipoA = "examen";
                      } else if(tipo.indexOf(true) == 1){
                        tipoA = "entrega";
                      }else if(tipo.indexOf(true) == 2 ){
                        tipoA = "evento";
                      }
                      final Appointment app = Appointment(
                        id: {
                          'asignatura_id': asignatura['id'],
                          'sesion_id': id,
                        },
                        startTime: hora.add(Duration(minutes: -1)),
                        endTime: hora,
                        color: colorMap[asignatura['color']]!,
                        subject: _nombreController.text,
                        notes: tipoA,
                      );
                      if(tipo.indexOf(true) == 0) {
                        _examenes.add(app);
                      } else if(tipo.indexOf(true) == 1){
                        _entregas.add(app);
                      }else if(tipo.indexOf(true) == 2 ){
                        _eventos.add(app);
                      }
                      _dataSource!.appointments.add(app);
                      _dataSource!.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);
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
}

class _EntregasDataSource extends CalendarDataSource {
  _EntregasDataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;

}

