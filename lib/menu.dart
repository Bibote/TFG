import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
      final user = FirebaseAuth.instance.currentUser!;
      return Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
        ),
        body: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Text('Bienvenido ${user.email}'),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        )
      );
  }
}