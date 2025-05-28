import 'package:flutter/material.dart';

class EventProfile extends StatelessWidget {
  final String titulo;
  EventProfile({required String this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        padding: EdgeInsets.all(10.0),
        color: const Color.fromRGBO(245, 238, 221, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titulo),
            ElevatedButton(
              onPressed: () {},
              child: Text("Sair"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color.fromARGB(255, 125, 7, 7),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
