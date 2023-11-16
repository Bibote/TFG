import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  _ClasesDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    getSesiones();
  }
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        children: [
          SfCalendar(
            view: CalendarView.schedule,
            firstDayOfWeek: 1,
            dataSource: _dataSource,

          ),
          Placeholder(),
          Placeholder(),
          Placeholder(),
          Placeholder(),
        ],
    );
  }

  Future<void> getSesiones()async{
    final horarioBL bl = horarioBL();

    List<Appointment> sesiones = await bl.getSesiones();
    setState(() {
      _dataSource = _ClasesDataSource(sesiones);
    });
  }
}

// Definir la fuente de datos del calendario
class _ClasesDataSource extends CalendarDataSource {
  _ClasesDataSource(List<Appointment> source) {
    appointments = source;
  }
}

