import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg/Educacion/Calendario/Calendario_edu.dart';
import 'package:tfg/Educacion/horario/horario_edu.dart';
import 'package:tfg/Inicio/Dashboard.dart';
import 'package:tfg/main.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final List<bool> _selectedModo = <bool>[true, false];
  final List<bool> _selectedLuz = <bool>[false, false, true];
  Widget _pantalla= Dashboard();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
    void cambioPagina(Widget pagina) {
      setState(() {
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
                cambioPagina(pantallaHorario());
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
                cambioPagina(MyHomePage());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.calendar_month, size: 32),
              label: Text("Entregas")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(Text("Planificador de examenes"));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.menu_book_outlined, size: 32),
              label: Text("Planificador de examenes")
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
                cambioPagina(Text("Calendario"));
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
                cambioPagina(Text("Gastos"));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.euro, size: 32),
              label: Text("Gastos")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(Text("Donde comemos?"));
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
                cambioPagina(Text("Valoración restaurantes"));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.restaurant_menu, size: 32),
              label: Text("Valoración restaurantes")
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 50),
              ),
              onPressed: () {
                cambioPagina(Text("Actividades"));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.celebration_rounded, size: 32),
              label: Text("Actividades")
          ),
        ],
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            onPressed: () {
              cambioPagina(const Dashboard());
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
                            user!.email!,
                            style: const TextStyle(fontSize: 15),
                            ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        icon: const Icon(Icons.logout),
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
                       onPressed: (int index) {
                         setState(() {
                           // The button that is tapped is set to true, and the others to false.
                           for (int i = 0; i < _selectedLuz.length; i++) {
                             _selectedLuz[i] = i == index;
                           }
                           if(_selectedLuz[0]){
                              MyApp.of(context).changeTheme(
                                  ThemeMode.light
                              );
                           }else if(_selectedLuz[1]){
                              MyApp.of(context).changeTheme(ThemeMode.dark);
                           } else{
                             MyApp.of(context).changeTheme(ThemeMode.system);
                           }
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
                         icon: const Icon(Icons.settings,size: 32),
                         onPressed: () {
                           cambioPagina(Text("Ajustes"));
                           Navigator.pop(context);
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
}




