import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:tfg/notification_manager/notification_manager.dart';


class pantallaPomodoro extends StatefulWidget {
  const pantallaPomodoro({super.key});

  @override
  _pantallaPomodoroState createState() => _pantallaPomodoroState();
}

class _pantallaPomodoroState extends State<pantallaPomodoro> {
  int descanso = 5;
  int trabajo = 25;
  int descansoLargo = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tiempo de descanso'),
              SizedBox(height: 5,),
              NumberPicker(
                  minValue: 1,
                  maxValue: 59,
                  value: descanso,
                  axis: Axis.horizontal,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  haptics: true,
                  onChanged: (value) => setState(() => this.descanso = value),
              ),
              SizedBox(height: 16,),
              Text('Tiempo de trabajo'),
              SizedBox(height: 5,),
              NumberPicker(
                  minValue: 1,
                  maxValue: 59,
                  value: trabajo,
                  axis: Axis.horizontal,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                haptics: true,
                  onChanged: (value) => setState(() => this.trabajo = value),
              ),
              SizedBox(height: 16,),
              Text('Tiempo de descanso largo'),
              SizedBox(height: 5,),
              NumberPicker(
                  minValue: 1,
                  maxValue: 59,
                  value: descansoLargo,
                  axis: Axis.horizontal,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                haptics: true,
                  onChanged: (value) => setState(() => this.descansoLargo = value),
              ),
              SizedBox(height: 16,),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => runningPomodoro(descansoLargo: Duration(minutes: descansoLargo), descanso: Duration(minutes: descanso), estudio: Duration(minutes: trabajo),)));
                  },
                  child: Text('Empezar'),
              ),
            ],
          ),
      ),
    )
    );
  }
}

class runningPomodoro extends StatefulWidget {
  runningPomodoro({super.key,required Duration this.descansoLargo, required Duration this.descanso, required Duration this.estudio});
  late Duration descansoLargo;
  late Duration descanso;
  late Duration estudio;

  @override
  _runningPomodoroState createState() => _runningPomodoroState();
}

class _runningPomodoroState extends State<runningPomodoro> {
  late Duration tiempo ;
  Color colorFondo = Colors.red.shade900;
  bool isRunning = false;
  Timer? timer;
  //Se divide en 4 fases
  int fase = 0;
  bool modoEstudio = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    isRunning = true;
    startTimer();
    counter();
  }

  void startTimer() {
    setState(() {
      tiempo = widget.estudio;
      isRunning = true;
    });
  }
  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void finCount() {
    if(modoEstudio) {
      if(fase == 3) {
        NotificationManager().simpleNotificacitonShow("Pomodoro", "Te has ganado un descanso largo");
        setState(() {
          colorFondo = Colors.green.shade800;
          modoEstudio = false;
          fase=0;
          tiempo = widget.descansoLargo;
        });
      } else {
        NotificationManager().simpleNotificacitonShow("Pomodoro", "Toca descansito");
        setState(() {
          colorFondo = Colors.amber.shade900;
          modoEstudio = false;
          fase++;
          tiempo = widget.descanso;
        });
      }
    }else {
        NotificationManager().simpleNotificacitonShow("Pomodoro", "Hora de volver a estudiar");
        setState(() {
          colorFondo = Colors.red.shade900;
          modoEstudio = true;
          tiempo = widget.estudio;
        });

    }
  }


  void counter() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if(tiempo.inSeconds > 0) {
          tiempo = tiempo - Duration(seconds: 1);
        } else {
          finCount();
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : colorFondo,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(modoEstudio ? 'Estudio' : 'Descanso', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTimeCard(time: tiempo.inMinutes.toString().padLeft(2,'0'), header: 'MINUTES',color: colorFondo, modoOscuro: Theme.of(context).brightness == Brightness.dark),
                  SizedBox(width: 16,),
                  buildTimeCard(time: tiempo.inSeconds.remainder(60).toString().padLeft(2,'0'), header: 'SECONDS',color: colorFondo, modoOscuro: Theme.of(context).brightness == Brightness.dark),
                ],
              ),
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancelar'),
                  ),
                  SizedBox(width: 16,),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if(isRunning) {
                            timer!.cancel();
                            isRunning = false;
                          }else {
                            counter();
                            isRunning = true;
                          }
                        });
                      },
                      child: isRunning ? Text('Pausar') : Text('Reanudar'),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }

}

Widget buildTimeCard({required String time, required String header, required Color color, required bool modoOscuro}) => Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.black, width: 3),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Text(
    time,
    style: TextStyle(
      color: modoOscuro ? color : Colors.black,
      fontSize: 60,
      fontWeight: FontWeight.bold,
    ),
  ),
);



