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
        onPressed: () {showDialogWithFields();},
        child: const Icon(Icons.add),
      ),
    );
  }
  void showDialogWithFields() {
    showDialog(
      context: context,
      builder: (_) {
        var emailController = TextEditingController();
        var messageController = TextEditingController();
        return AlertDialog(
          title: Text('Añadir asignatura'),
          content: Container(
            height: MediaQuery.of(context).size.height*0.50,
            width: MediaQuery.of(context).size.width*0.75,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                ),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(hintText: 'Message'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Send them to your email maybe?
                var email = emailController.text;
                var message = messageController.text;
                Navigator.pop(context);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}

