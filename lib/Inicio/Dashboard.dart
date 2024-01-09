import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:tfg/Educacion/Calendario/entregas_ed_bl.dart';
import 'package:tfg/Educacion/Horario/horario_edu_bl.dart';
import 'package:tfg/Ocio/Calendario/calendario_oci_bl.dart';
import 'package:tfg/notification_manager/notification_manager.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);


  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  _ClasesDataSource? _dataSource;
  _ClasesDataSource? _dataSourceEventos;
  _ClasesDataSource? _dataSourceOcio;

  @override
  void initState() {
    getSesiones();
    getEventos();
    getOcio();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return ListView(
        children: [
            SizedBox(height: 20,),
            Text("Horario de clases",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),),
            SfCalendar(
              view: CalendarView.schedule,
              firstDayOfWeek: 1,
              dataSource: _dataSource,
            ),
            SizedBox(height: 20,),
            const Text(
                "Examenes y entregas",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SfCalendar(
              view: CalendarView.schedule,
              firstDayOfWeek: 1,
              dataSource: _dataSourceEventos,
            ),
            SizedBox(height: 20,),
            Text(
                "Eventos",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
          SfCalendar(
            view: CalendarView.schedule,
            firstDayOfWeek: 1,
            dataSource: _dataSourceOcio,
          ),
            CustomButton(onPressed: () {
            print("a vwer");
            NotificationManager().scheduleNotification(DateTime.now().millisecondsSinceEpoch% (1 << 31),"titulo", "cuerpo", DateTime.now().add(Duration(seconds: 10)));
            },
            title: "notiSchedule"),
          CustomButton(onPressed: () {
            print("hola");
            NotificationManager().simpleNotificacitonShow("hola", "hola");
          }, title: "notiSimple"),
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
    });
  }

  Future<void> getOcio() async {
    final EventosBL bl = EventosBL();
    List<Appointment> sesiones = await bl.getEventos();
    setState(() {
      _dataSourceOcio = _ClasesDataSource(sesiones);
    });
  }
}

class _ClasesDataSource extends CalendarDataSource {
  _ClasesDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  const CustomButton({Key? key, required this.onPressed, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.blueGrey, spreadRadius: 1, blurRadius: 8),
            ]),
        child:  Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

