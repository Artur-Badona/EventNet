import 'package:flutter/material.dart';

class EventPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: 390,
        color: const Color.fromRGBO(245, 238, 221, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Titulo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
            Image.network(
              "https://falamarilia.com.br/wp-content/uploads/2025/04/1000205380-1024x768.jpg",
            ),
            Text(
              "Lorem ipsum dolor sit amet. Cum incidunt repellat est totam tempora non ipsa veritatis eos illum officia. Cum ipsam cumque ut odio fugiat cum recusandae maxime. Aut debitis rerum aut delectus nesciunt id delectus incidunt ut sequi recusandae sed voluptatem aspernatur.",
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
