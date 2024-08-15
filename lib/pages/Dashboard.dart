import 'package:flutter/material.dart';
import 'AppLayout.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      body: Center(
          child: Column(children: [
        SizedBox(height: 100),
        Icon(
          Icons.print,
          color: Color.fromARGB(255, 101, 101, 101),
          size: 200.0,
        ),
        SizedBox(height: 20),
        Text('Welcome Admin!',
            style: TextStyle(color: Colors.black, fontSize: 20.0)),
      ])),
    );
  }
}
