// main.dart
import 'package:event_net/home.dart';
import 'package:event_net/profile.dart';
import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ProfilePage(), debugShowCheckedModeBanner: false);
  }
}
