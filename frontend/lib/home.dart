import 'package:event_net/event.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventNet", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person, color: Colors.white, size: 40),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            EventPost(
              titulo: "Titulo",
              descricao:
                  "Lorem ipsum dolor sit amet. Cum incidunt repellat est totam tempora non ipsa veritatis eos illum officia. Cum ipsam cumque ut odio fugiat cum recusandae maxime. Aut debitis rerum aut delectus nesciunt id delectus incidunt ut sequi recusandae sed voluptatem aspernatur.",
              imagem_url:
                  "https://falamarilia.com.br/wp-content/uploads/2025/04/1000205380-1024x768.jpg",
            ),
            SizedBox(height: 40),
            EventPost(
              titulo: "Titulo",
              descricao:
                  "Lorem ipsum dolor sit amet. Cum incidunt repellat est totam tempora non ipsa veritatis eos illum officia. Cum ipsam cumque ut odio fugiat cum recusandae maxime. Aut debitis rerum aut delectus nesciunt id delectus incidunt ut sequi recusandae sed voluptatem aspernatur.",
              imagem_url:
                  "https://falamarilia.com.br/wp-content/uploads/2025/04/1000205380-1024x768.jpg",
            ),
            SizedBox(height: 40),
            EventPost(
              titulo: "Titulo",
              descricao:
                  "Lorem ipsum dolor sit amet. Cum incidunt repellat est totam tempora non ipsa veritatis eos illum officia. Cum ipsam cumque ut odio fugiat cum recusandae maxime. Aut debitis rerum aut delectus nesciunt id delectus incidunt ut sequi recusandae sed voluptatem aspernatur.",
              imagem_url:
                  "https://falamarilia.com.br/wp-content/uploads/2025/04/1000205380-1024x768.jpg",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
