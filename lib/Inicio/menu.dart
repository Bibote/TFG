import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/Educacion/Calendario/entregas_edu.dart';
import 'package:tfg/Educacion/pomodoro.dart';
import 'package:tfg/Inicio/Dashboard.dart';
import 'package:tfg/Inicio/menu_bl.dart';
import 'package:tfg/Ocio/Calendario/calendario_oci.dart';
import 'package:tfg/Ocio/Grupos/grupos.dart';
import 'package:tfg/Ocio/Restaurantes/restaurantes.dart';
import 'package:tfg/main.dart';

import '../Educacion/Horario/horario_edu.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final List<bool> _selectedModo = <bool>[true, false];
  final List<bool> _selectedLuz = <bool>[false, false, true];
  Widget _pantalla= Dashboard();
  String titulo = "Menu Principal";
  String _user = "";
  @override
  void initState() {
    menuBL().getNombre().then((value) {
      setState(() {
        _user =value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (MyApp.of(context).getTheme() == ThemeMode.light) {
      _selectedLuz[0] = true;
      _selectedLuz[1] = false;
      _selectedLuz[2] = false;
    } else if (MyApp.of(context).getTheme()   == ThemeMode.dark) {
      _selectedLuz[0] = false;
      _selectedLuz[1] = true;
      _selectedLuz[2] = false;
    } else {
      _selectedLuz[0] = false;
      _selectedLuz[1] = false;
      _selectedLuz[2] = true;
    }
    void cambioPagina(Widget pagina, String titulo) {
      setState(() {
        this.titulo = titulo;
        _pantalla = pagina;
      });
    }


    final List<Widget> _menus = <Widget>[
      //Botones de la parte académica
      Column(
        children: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(pantallaHorario(), "Horario de clases");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.calendar_month, size: 32),
              label: Text("Horario de clases")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(EntregasPage(), "Calendario de entregas");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.calendar_month, size: 32),
              label: Text("Entregas/Examenes")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(pantallaPomodoro(), "Pomodoro");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.alarm, size: 32),
              label: Text("Pomodoro")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(runningPomodoro(descanso: Duration(seconds: 5),estudio: Duration(seconds: 25),descansoLargo: Duration(seconds: 15)), "Pomodoro");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.alarm, size: 32),
              label: Text("Pomodoro")
          ),
        ],
      ),
      //Botones de la parte lúdica
      Column(
        children: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(EventosPage(), "Calendario de eventos");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.calendar_month, size: 32),
              label: Text("Calendario")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(pantallaGrupos(), "Grupos");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.people, size: 32),
              label: Text("Grupos")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(pantallaRestaurantes(),"Seleccionador de restaurantes");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.restaurant, size: 32),
              label: Text("Donde comemos?")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(Text("Actividades"), "Actividades");
                Navigator.pop(context);
              },
              icon: const Icon(Icons.celebration_rounded, size: 32),
              label: Text("Actividades")
          ),
        ],
      ),
    ];
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            onPressed: () {
              cambioPagina(const Dashboard(), "Menu Principal");
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Center(
        child: _pantalla,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Row(
                  children: [
                      const Icon(Icons.account_circle_rounded, size: 50),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            _user,
                            style: const TextStyle(fontSize: 15),
                            ),
                      ),
                      IconButton(
                        onPressed: ()  {
                          editarNombre();
                        },
                        icon: const Icon(Icons.edit),
                      ),

                  ],
                 ),
               ),
              const Divider(
                height: 20,
                thickness: 5,
                indent: 20,
                endIndent: 20,
              ),
              Center(
                child: ToggleButtons(
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _selectedModo.length; i++) {
                        _selectedModo[i] = i == index;
                      }
                    });
                  },
                  constraints: const BoxConstraints(minWidth: 120, minHeight: 60),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  isSelected: _selectedModo,
                  children: const <Widget>[
                    Icon(Icons.school_rounded),
                    Icon(Icons.celebration_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child:_menus[_selectedModo.indexOf(true)]
              ),
               const Spacer(
                   flex: 1
               ),
              Padding(
                 padding: const EdgeInsets.all(16.0),
                 child:  Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     ToggleButtons(
                       onPressed: (int index) async {
                         ThemeMode themeMode;
                         SharedPreferences prefs= await SharedPreferences.getInstance();
                          for (int i = 0; i < _selectedLuz.length; i++) {
                            _selectedLuz[i] = i == index;
                          }
                         if(_selectedLuz[0]){
                           themeMode = ThemeMode.light;
                           prefs.setString('theme', 'light');
                         }else if(_selectedLuz[1]){
                            themeMode = ThemeMode.dark;
                            prefs.setString('theme', 'dark');
                         } else{
                            themeMode = ThemeMode.system;
                            prefs.setString('theme', 'system');
                         }
                         setState(() {
                           // The button that is tapped is set to true, and the others to false.
                           MyApp.of(context).changeTheme(themeMode);

                         });
                       },
                       constraints: const BoxConstraints(minWidth: 60, minHeight: 30),
                       borderRadius: const BorderRadius.all(Radius.circular(8)),
                       isSelected: _selectedLuz,
                       children: const <Widget>[
                         Icon(Icons.sunny),
                         Icon(Icons.nightlight),
                         Icon((Icons.system_security_update_good))
                       ],
                     ),
                     const Spacer(),
                     IconButton(
                         icon: const Icon(Icons.logout_outlined,size: 32),
                         onPressed: () async {
                           await FirebaseAuth.instance.signOut();
                         }
                     ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      )
    );
  }
  void editarNombre() {
    var nombreController = TextEditingController();
    nombreController.text = _user;
    showDialog(context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Editar nombre"),
            content: TextField(
              controller: nombreController,
              onChanged: (String value) {
                _user = value;
              },
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar")
              ),
              TextButton(
                  onPressed: () async {
                    bool resul = await menuBL().setNombre(_user);
                    if(resul){
                      setState(() {
                        _user = nombreController.text;
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Aceptar")
              ),
            ],
          );
        }
    );
  }
}




