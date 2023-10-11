import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final List<bool> _selectedModo = <bool>[true, false];

  final List<Widget> _menus = <Widget>[
     Column(
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
      ],
    ),
    Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(200, 50),
          ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: Text("data")
        ),
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bienvenido'),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
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
            )

          ],
        ),
      )
    );
  }
}




