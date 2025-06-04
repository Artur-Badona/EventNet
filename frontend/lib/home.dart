import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'create_event_page.dart';
import 'profile.dart';
import 'event.dart';
import 'dart:async';

class Categoria {
  final int id;
  final String nome;

  Categoria({required this.id, required this.nome});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nome: json['nome'],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Evento> eventos = [];
  List<Evento> eventosFiltrados = [];
  List<Categoria> _categorias = [];

  String? filtroLocalizacao;
  int? filtroCategoria;
  DateTime? filtroData;

  @override
  void initState() {
    super.initState();
    carregarEventos();
    carregarCategorias();
  }

  Future<void> carregarCategorias() async {
    final url = Uri.parse('http://10.0.2.2:8000/categorias');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _categorias = data.map((e) => Categoria.fromJson(e)).toList();
        });
      } else {
        print('Erro ao carregar categorias: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar categorias: $e');
    }
  }

  Future<void> carregarEventos() async {
    final url = Uri.parse('http://10.0.2.2:8000/eventos');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> dados = jsonDecode(utf8.decode(response.bodyBytes));
        final List<Evento> eventosRecebidos = dados.map((e) => Evento.fromJson(e)).toList();

        setState(() {
          eventos = eventosRecebidos;
          eventosFiltrados = eventosRecebidos;
        });
      } else {
        print('Erro ao carregar eventos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
    }
  }

  void aplicarFiltros() {
    setState(() {
      eventosFiltrados = eventos.where((evento) {
        final filtroLoc = filtroLocalizacao?.toLowerCase() ?? '';
        final localMatch = evento.localizacao.toLowerCase().contains(filtroLoc);

        final categoriaMatch = filtroCategoria == null || evento.idCategoria == filtroCategoria;
        final dataMatch = filtroData == null || evento.dataEvento.day == filtroData!.day;

        return localMatch && categoriaMatch && dataMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventNet", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfilePage()),
              );

              if (result == true) {
                carregarEventos();
              }
            },
            icon: Icon(Icons.person, color: Colors.white, size: 40),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Filtros
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Localização', filled: true, fillColor: Colors.white),
                    onChanged: (value) {
                      filtroLocalizacao = value;
                      aplicarFiltros();
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: filtroCategoria,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Categoria',
                    ),
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ..._categorias.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Text(cat.nome),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        filtroCategoria = value;
                        aplicarFiltros();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.date_range, color: Colors.white),
                  onPressed: () async {
                    final data = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (data != null) {
                      filtroData = data;
                      aplicarFiltros();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: eventosFiltrados.isEmpty
                  ? Center(child: Text("Nenhum evento encontrado", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: eventosFiltrados.length,
                      itemBuilder: (context, index) {
                        final evento = eventosFiltrados[index];
                        return Column(
                          children: [
                            EventPost(
                              id: evento.id,
                              titulo: evento.titulo,
                              descricao: evento.descricao,
                              imagem_url: evento.imagem,
                              localizacao: evento.localizacao,
                              dataEvento: evento.dataEvento,
                              dataFimInscricao: evento.dataFimInscricao,
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(7, 122, 125, 1),
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateEventPage()),
          );

          if (result == true) {
            carregarEventos();
          }
        },
        tooltip: 'Criar novo evento',
      ),
    );
  }
}

class Evento {
  final int id;
  final String titulo;
  final String descricao;
  final String imagem;
  final String localizacao;
  final int idCategoria;
  final DateTime dataEvento;
  final DateTime dataFimInscricao;

  Evento({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.imagem,
    required this.localizacao,
    required this.idCategoria,
    required this.dataEvento,
    required this.dataFimInscricao,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      imagem: json['imagem'],
      localizacao: json['localizacao'],
      idCategoria: json['id_categoria'],
      dataEvento: DateTime.parse(json['data_evento']),
      dataFimInscricao: DateTime.parse(json['data_fim_inscricao']),
    );
  }
}
