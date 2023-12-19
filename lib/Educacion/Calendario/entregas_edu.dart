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
    filtrar();
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
    else if (details.targetElement == CalendarElement.calendarCell) {
      print("calendarCell");
      crearSesion(context, details.date!);
    }
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
              content: Container(
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
                    SizedBox(height: 10),
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
                    Text("Nombre"),
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

