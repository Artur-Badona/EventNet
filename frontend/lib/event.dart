import 'package:flutter/material.dart';

class EventPost extends StatelessWidget {
  final String titulo;
  final String descricao;
  final String imagem_url;
  EventPost({
    super.key,
    required String this.titulo,
    required String this.descricao,
    required String this.imagem_url,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10.0),
        width: 350,
        color: const Color.fromRGBO(245, 238, 221, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 400,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.network(
                imagem_url,
                // "https://falamarilia.com.br/wp-content/uploads/2025/04/1000205380-1024x768.jpg",
              ),
            ),
            SizedBox(height: 20),
            Text(
              descricao,
              // "Lorem ipsum dolor sit amet. Cum incidunt repellat est totam tempora non ipsa veritatis eos illum officia. Cum ipsam cumque ut odio fugiat cum recusandae maxime. Aut debitis rerum aut delectus nesciunt id delectus incidunt ut sequi recusandae sed voluptatem aspernatur.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text("Entrar"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color.fromRGBO(7, 122, 125, 1),
                foregroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
