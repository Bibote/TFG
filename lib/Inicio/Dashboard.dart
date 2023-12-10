import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_ed_bl.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  _ClasesDataSource? _dataSource;
  _ClasesDataSource? _dataSourceEventos;

  @override
  void initState() {
    getSesiones();
    getEventos();
    super.initState();
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
          SfCalendar(
            view: CalendarView.schedule,
            firstDayOfWeek: 1,
            dataSource: _dataSourceEventos,
          ),
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
  Future<void> getEventos() async {
    final EntregasBL bl = EntregasBL();
    Map sesiones = await bl.getEventos();
    setState(() {
      _dataSourceEventos = _ClasesDataSource([...sesiones['entregas'],...sesiones['examenes'],...sesiones['eventos']]);
      print("Eventos");
      print(_dataSourceEventos);
    });
  }
}

// Definir la fuente de datos del calendario
class _ClasesDataSource extends CalendarDataSource {
  _ClasesDataSource(List<Appointment> source) {
    appointments = source;
  }
}

