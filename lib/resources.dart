import 'package:flutter/material.dart';

Map<String, Color> colorMap = {
  'Rojo': Colors.red,
  'Verde': Colors.green,
  'Azul': Colors.blue,
  'Amarillo': Colors.yellow,
  'Naranja': Colors.orange,
  'Rosa': Colors.pink,
  'Morado': Colors.purple,
  'Cian': Colors.cyan,
  'Marrón': Colors.brown,
  'Gris': Colors.grey,
  'Lima': Colors.lime,
  'Índigo': Colors.indigo,
};


class DropdownColor extends StatefulWidget {
  DropdownColor({required this.onColorSelected, required this.preColor});
  final ValueChanged<String> onColorSelected;
  late final String preColor;
  @override
  _DropdownColorState createState() => _DropdownColorState();
}

class _DropdownColorState extends State<DropdownColor> {

  String dropdownValue = 'Rojo';

  @override
  void initState() {
    if (widget.preColor != "") {
      widget.onColorSelected(widget.preColor);
      dropdownValue = widget.preColor;
    } else {
      widget.onColorSelected("Rojo");
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      //style: TextStyle(color: colorMap[dropdownValue]),
      underline: Container(
        height: 2,
        color: colorMap[dropdownValue],
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
          widget.onColorSelected(dropdownValue);
        });
      },
      items: colorMap.keys.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: colorMap[value],
                radius: 10,
              ),
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        );
      }).toList(),
    );
  }
}