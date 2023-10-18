import 'package:flutter/material.dart';
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
      floatingActionButton:FloatingActionButton(
        onPressed: (){},
        child: const Icon(Icons.add),
      ),
    );
  }
}