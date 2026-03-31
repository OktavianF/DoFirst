import 'package:flutter/material.dart';

class MyBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      print('constraints: $constraints');
      return Container(width: 10, height: 10, color: Colors.red);
    });
  }
}
