import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_ed_bl.dart';
import 'package:tfg/Ocio/Calendario/calendario_oci_bl.dart';



_EntregasDataSource? _dataSource;
List<Appointment> _eventosEducacion = [];
List<Appointment> _eventosOcio = [];

class EventosPage extends StatefulWidget {
  const EventosPage({Key? key}) : super(key: key);

  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  bool educacionChecked = false;
  List selecionados = [];

  final CalendarController calendarController = CalendarController();



  @override
  initState() {
    super.initState();
  }
  Future<void> getEventos() async {
    final EventosBL bl = EventosBL();
    final EntregasBL blEdu = EntregasBL();
    Map sesiones = await blEdu.getEventos();
    List<Appointment> eventos = await bl.getEventos();
      _eventosEducacion = _eventosEducacion= [...sesiones['entregas'],...sesiones['examenes'],...sesiones['eventos']];
      _eventosOcio = eventos;
    _dataSource = _EntregasDataSource(_eventosOcio);
  }

  void filtrar() {
    if(educacionChecked) {
      setState(() {
        _dataSource = _EntregasDataSource([..._eventosOcio,..._eventosEducacion]);
      });
    } else {
      setState(() {
        _dataSource = _EntregasDataSource(_eventosOcio);
      });
    }
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
                Text("Mostrar eventos de educación"),
                Checkbox(
                    value: educacionChecked,
                    onChanged: (value) {
                      setState(() {
                        educacionChecked = value!;
                        filtrar();
                      });
                    }
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: getEventos(),
                builder: (context,snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }else if(snapshot.hasError) {
                    return const Center(child: Text("Error al cargar los eventos"));
                  }else {
                    return SfCalendar(
                      dataSource: _dataSource,
                      firstDayOfWeek: 1,
                      view: CalendarView.month,
                      onTap: calendarTap,
                      allowedViews: [
                        CalendarView.week,
                        CalendarView.month,
                      ],
                      monthViewSettings: const MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode
                            .appointment,
                        showAgenda: true,
                      ),
                    );
                  }
                }
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
      if (evento.notes != "ocio") {
        return;
      }
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
                  if(await EventosBL().eliminarEvento(evento.id )) {
                    _dataSource?.appointments.remove(evento);
                    _dataSource?.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[evento]);
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
    DateTime hora = selectedDate.add(Duration(hours: 12));
    DateTime horaFin = selectedDate.add(const Duration(hours: 1));
    TextEditingController _nombreController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text('Crear evento')),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Text("Nombre"),
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        hintText: 'Nombre',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Hora de inicio:"),
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
                    const Text("Hora final:"),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(DateFormat('yyyy-MM-dd   hh:mm').format(horaFin)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDateFin = await showDatePicker(
                              context: context,
                              initialDate: horaFin,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2025),
                            );
                            if (pickedDateFin != null) {
                              setState(() {
                                horaFin = DateTime(
                                  pickedDateFin.year,
                                  pickedDateFin.month,
                                  pickedDateFin.day,
                                  horaFin.hour,
                                  horaFin.minute,
                                );
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () async {
                            final TimeOfDay? pickedTimeFin = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(horaFin),
                            );
                            if (pickedTimeFin != null) {
                              setState(() {
                                horaFin = DateTime(
                                  horaFin.year,
                                  horaFin.month,
                                  horaFin.day,
                                  pickedTimeFin.hour,
                                  pickedTimeFin.minute,
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
                      if(_nombreController.text.isNotEmpty) {
                          String id = await EventosBL().crearEvento(_nombreController.text, hora, horaFin, _nombreController.text);
                          if(id == "") return null;
                          Appointment app = Appointment(
                            id: id,
                            isAllDay: false,
                            subject: _nombreController.text,
                            color: Colors.teal,
                            notes: "ocio",
                            startTime: hora,
                            endTime: horaFin,
                          );
                          setState(() {

                            _dataSource!.appointments.add(app);
                            _dataSource!.notifyListeners(CalendarDataSourceAction.add, <Appointment>[app]);

                          });
                      }
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
