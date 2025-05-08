// main.dart
import 'package:flutter/material.dart';
import 'login.dart'; // Importa a LoginPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Example',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginPage(), // Define LoginPage como a primeira tela
    );
  }
}
