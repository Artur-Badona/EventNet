import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventPost extends StatelessWidget {
  final int id;
  final String titulo;
  final String descricao;
  final String imagem_url;
  final String localizacao;

  EventPost({
    super.key,
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagem_url,
    required this.localizacao,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black54, size: 20),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    localizacao,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagem_url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      height: 200,
                      alignment: Alignment.center,
                      child: Text('Falha ao carregar imagem', style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('jwt_token');

                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Faça login para se inscrever.')),
                    );
                    return;
                  }

                  final url = Uri.parse('http://10.0.2.2:8000/inscricoes');

                  try {
                    final response = await http.post(
                      url,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode({'id_evento': id}),
                    );

                    if (response.statusCode == 201 || response.statusCode == 200) {
                      final data = jsonDecode(utf8.decode(response.bodyBytes));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(data['mensagem'] ?? 'Inscrição realizada com sucesso')),
                      );
                    } else {
                      final error = jsonDecode(utf8.decode(response.bodyBytes));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro: ${error['detail'] ?? 'Falha na inscrição'}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro de conexão: $e')),
                    );
                  }
                },
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
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
