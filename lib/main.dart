import 'package:exodus_app/pages/ClientForm.dart';
import 'package:exodus_app/pages/home.dart';

import 'pages/Dashboard.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}
