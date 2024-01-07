import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tfg/Inicio/menu.dart';
import 'package:tfg/Login/login.dart';
import 'package:tfg/notification_manager/notification_manager.dart';
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
  NotificationManager().initNotification();
  await dotenv.load(fileName: ".env");
  ThemeMode modoCarga = ThemeMode.system;
  await SharedPreferences.getInstance().then((prefs) {
    if(prefs.getString('theme') == null) {
      prefs.setString('theme', 'system');
    }else {
      switch(prefs.getString('theme')) {
        case 'system':
          modoCarga = ThemeMode.system;
          break;
        case 'light':
          modoCarga = ThemeMode.light;
          break;
        case 'dark':
          modoCarga = ThemeMode.dark;
          break;
      }
    }
  });
  runApp(MyApp(modo: modoCarga));


}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.modo}) : super(key: key);
  final ThemeMode modo;

  @override
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  // This widget is the root of your application.
  @override
  void initState() {
    _themeMode = widget.modo;
    super.initState();
  }
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
      darkTheme: ThemeData.dark(
        useMaterial3: false
      ),
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



