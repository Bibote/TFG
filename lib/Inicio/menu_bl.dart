
import 'package:image_picker/image_picker.dart';

import 'menu_bd.dart';

class menuBL {
  static final menuBL _instancia = menuBL._privado();
  factory menuBL() {
    return _instancia;
  }
  menuBL._privado();

  Future<Map> getUser() async {
    return await menuBD().getUser();
  }

  Future<Map>setNombre(String user) async {
    if(user =="") return {'error': 'El nombre no puede estar vacio'};
    if(user.length>15) return {'error': 'El nombre no puede ser mayor a 15 caracteres'};
    if(await menuBD().setNombre(user)){
      return {'success': 'Nombre actualizado'};
    } else {
      return {'error': 'Error al actualizar el nombre, pruebe de nuevo más tarde'};
    }

  }

  Future<String> subirImagen(XFile url) async {
    if(url.path == "") return "";
    return await menuBD().subirImagen(url);
  }


}