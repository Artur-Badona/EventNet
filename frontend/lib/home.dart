// HomePage.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Página Principal')),
      body: Center(
        child: Text(
          'Bem-vindo à Página Principal!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
