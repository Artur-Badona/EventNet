import 'package:event_net/event.dart';
import 'package:event_net/event_profile.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventNet", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.white, size: 40),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            EventProfile(titulo: "Titulo"),
            SizedBox(height: 30),
            EventProfile(titulo: "Titulo"),
            SizedBox(height: 30),
            EventProfile(titulo: "Titulo"),
          ],
        ),
      ),
    );
  }
}
