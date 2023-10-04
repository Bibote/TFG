import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:tfg/main.dart';


class Registro extends StatelessWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
  @override
  void dispose() {
    emailController.dispose();
    contra1Controller.dispose();
    contra2Controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        TextField(
          controller: emailController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: contra1Controller,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Contraseña',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: contra2Controller,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Repita la contraseña',
          ),
        ),
        /*
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
          icon: Icon(Icons.lock_open, size: 32),
          label: Text(
            'Sign In',
            style: TextStyle(fontSize: 24),
          ),
          onPressed: signIn,
        ),*/
        RichText(
          text: TextSpan(
            text: '¿Ya tienes una cuenta? ',
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                text: 'Iniciar sesión',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

}
