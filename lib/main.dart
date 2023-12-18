import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tfg/Inicio/menu.dart';
import 'package:tfg/Login/login.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async {
  //SyncfusionLicense.registerLicense(licencia_syncfusion);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  runApp(const MyApp());


}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        SfGlobalLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        //Locale('en'),
      ],
      locale: const Locale('es'),
      debugShowCheckedModeBanner:false,
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: App(),
    );
  }
  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  ThemeMode getTheme() {
    return _themeMode;
  }
}
class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context,snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if(snapshot.hasError) {
                return const Center(child: Text('Ha ocurrido un error'));
              } else if (snapshot.hasData) {
                return const Menu();
              } else {
                return LoginWidget();
              }
            }
        )
    );
  }
}



