
import 'menu_bd.dart';

class menuBL {
  static final menuBL _instancia = menuBL._privado();
  factory menuBL() {
    return _instancia;
  }
  menuBL._privado();

  Future <String> getNombre() async {
    return await menuBD().getNombre();
  }

  Future<bool>setNombre(String user) async {
    if(user =="") return false;
    if(user.length>20) return false;
    return await menuBD().setNombre(user);

  }


}