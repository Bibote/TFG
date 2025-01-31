import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tfg/Login/registro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:tfg/main.dart';


class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}
class _LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = "";
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  void cambioError(String texto){
    setState(() {
      error = texto;
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
                const Image(image: AssetImage('assets/icon_no_bg.png'), height: 350, width: 350),
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
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Password',
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
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: signIn,
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    ),
                    text: '¿No tienes una cuenta? ',
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Registro()),
                            );
                          },
                        text: 'Registrarse',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  child: Container(
                      width: 250,
                      height: 50,
                      margin: const EdgeInsets.only(top: 25),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color:Colors.black
                      ),
                      child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image:
                                      AssetImage('assets/google.png'),
                                      fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Text('Iniciar sesión con Google',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                            ],
                          )
                      )
                  ),
                  onTap: (){
                    signInWithGoogle();
                  },
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

  Future signIn() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      cambioError("Rellene todos los campos.");
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-email') {
        cambioError("Contraseña o usuario incorrecto.");
      } else if (e.code == 'user-disabled') {
        cambioError('Usuario deshabilidado.');
      } else {
        print(e);
        cambioError('Ha ocurrido un error con el servidor pruebe en otro momento.');
      }
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseFirestore db = FirebaseFirestore.instance;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator())
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      var usersRef = db.collection('usuarios').doc(FirebaseAuth.instance.currentUser?.uid);
      String nombre;
      nombre = FirebaseAuth.instance.currentUser?.email!.split('@')[0] ?? "";
      await usersRef.get()
          .then((docSnapshot) => {
        if (!docSnapshot.exists) {
          //Como nombre se pondra lo que hay antes del @

          usersRef.set({
            'email': FirebaseAuth.instance.currentUser?.email,
            'nombre': nombre,
          })
        }
      });
    } on FirebaseAuthException catch (e) {
      cambioError("Ha ocurrido un error con el servidor pruebe en otro momento.");
      print(e);
      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);

  }
}