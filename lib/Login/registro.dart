import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:tfg/Login/login.dart';
import 'package:tfg/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Inicio/menu.dart';



class Registro extends StatelessWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RegistroWidget(),
    );
  }
}

class RegistroWidget extends StatefulWidget {
  const RegistroWidget({Key? key}) : super(key: key);

  @override
  _RegistroWidgetState createState() => _RegistroWidgetState();
}

class _RegistroWidgetState extends State<RegistroWidget>{
  final emailController = TextEditingController();
  final contra1Controller = TextEditingController();
  final contra2Controller = TextEditingController();
  String error = "";
  @override
  void dispose() {
    emailController.dispose();
    contra1Controller.dispose();
    contra2Controller.dispose();
    super.dispose();
  }
  void cambioError(String texto){
    setState(() {
      error = texto;
    });
  }
  void creado(){
    setState(() {
      error = "Usuario creado correctamente";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FlutterLogo(
                size: 200,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: contra1Controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: contra2Controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Repita la contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.lock_open, size: 32),
                label: const Text(
                  'Registrarse',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: registro,
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const App()),
                        );
                      },
                      text: 'Iniciar sesión',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                error,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
    Future registro() async {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator())
      );
      if (contra1Controller.text.trim()==contra2Controller.text.trim()) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: contra1Controller.text.trim(),
          );
          FirebaseFirestore db = FirebaseFirestore.instance;
          await db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid).set({
            'email': emailController.text.trim(),
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Menu()),);
        } on FirebaseAuthException catch(e) {
          if (e.code == 'weak-password') {
            cambioError("La contraseña es demasiado débil");
          } else if (e.code == 'email-already-in-use') {
            cambioError("Ya existe una cuenta con ese email");
          } else if(e.code == 'invalid-email'){
            cambioError("Email no válido");
          }
          else {
            print(e.code);
            cambioError("Error desconocido");
          }
        }
      } else {
        cambioError("Las contraseñas no coinciden");
      }
      navigatorKey.currentState!.pop();
    }
  }


