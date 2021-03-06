import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(SpeedDialDemo());

class SpeedDialDemo extends StatelessWidget{
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(),
        floatingActionButton: _SpeedDialDemo(),
    );
  }
}

class _SpeedDialDemo extends StatefulWidget {
  _SpeedDialDemoState createState() => _SpeedDialDemoState();
}

class _SpeedDialDemoState extends State<_SpeedDialDemo> {
  IconData _icon;

  Widget build (BuildContext context) {
    return SpeedDial(
        curve: Curves.linear,
        animationSpeed: 300,
        child: Icon(_icon ?? Icons.list),
        children:[
          SpeedDialChild(
              child: Icon(Icons.accessibility),
              backgroundColor: Colors.red,
              onTap: () => print('FIRST CHILD')
          ),
          SpeedDialChild(
            child: Icon(Icons.brush),
            backgroundColor: Colors.orange,
            onTap: () => print('SECOND CHILD'),
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard_voice),
            backgroundColor: Colors.green,
            onTap: () => print('THIRD CHILD'),
          ),
        ]
    );
  }
}