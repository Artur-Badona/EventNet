import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_net/event_profile.dart';

class Event {
  final int id;
  final String titulo;
  final String descricao;
  final DateTime dataEvento; 

  Event({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataEvento,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataEvento: DateTime.parse(json['data_evento']),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Event> eventosInscritos = [];
  List<Event> eventosCriados = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchEventos();
  }

  Future<void> sairDoEvento(int idEvento) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    final url = "http://10.0.2.2:8000/inscricao/evento/$idEvento";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final res = await http.delete(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Você saiu do evento com sucesso!')),
      );
      fetchEventos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair do evento: ${res.statusCode}')),
      );
    }
  }

  Future<void> apagarEvento(int idEvento) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    final url = "http://10.0.2.2:8000/evento/$idEvento";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final res = await http.delete(Uri.parse(url), headers: headers);
    if (res.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento apagado com sucesso!')),
      );
      fetchEventos();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar evento: ${res.statusCode}')),
      );
    }
  }

  Future<void> fetchEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado. Faça login novamente.')),
      );
      return;
    }

    const baseUrl = "http://10.0.2.2:8000";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final inscritosRes = await http.get(Uri.parse("$baseUrl/eventos/inscrito"), headers: headers);
      final publicadosRes = await http.get(Uri.parse("$baseUrl/eventos/publicados"), headers: headers);

      if (inscritosRes.statusCode == 200 && publicadosRes.statusCode == 200) {
        setState(() {
          eventosInscritos = List<Event>.from(
            json.decode(utf8.decode(inscritosRes.bodyBytes)).map((e) => Event.fromJson(e)),
          );
          eventosCriados = List<Event>.from(
            json.decode(utf8.decode(publicadosRes.bodyBytes)).map((e) => Event.fromJson(e)),
          );
          isLoading = false;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao carregar eventos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }
  }


  Widget buildEventList(List<Event> eventos, {bool isCriados = false}) {
    return eventos.isEmpty
        ? Center(child: Text("Nenhum evento encontrado", style: TextStyle(color: Colors.white)))
        : ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 20),
            itemCount: eventos.length,
            separatorBuilder: (_, __) => SizedBox(height: 20),
            itemBuilder: (context, index) {
              final e = eventos[index];
              return Card(
                color: const Color.fromRGBO(15, 59, 79, 1),
                child: ListTile(
                  title: Text(e.titulo, style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    "Data: ${e.dataEvento.day.toString().padLeft(2, '0')}/"
                    "${e.dataEvento.month.toString().padLeft(2, '0')}/${e.dataEvento.year} "
                    "às ${e.dataEvento.hour.toString().padLeft(2, '0')}:${e.dataEvento.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: isCriados
                      ? IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirmar'),
                                content: Text('Deseja apagar o evento "${e.titulo}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      apagarEvento(e.id);
                                    },
                                    child: Text('Apagar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.exit_to_app, color: Colors.orangeAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Confirmar'),
                                content: Text('Deseja sair do evento "${e.titulo}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      sairDoEvento(e.id);
                                    },
                                    child: Text('Sair'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventProfile(titulo: e.titulo)),
                    );

                    if (result == true) {
                      fetchEventos();
                    }
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: Text("EventNet", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.white, size: 30),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Inscritos"),
            Tab(text: "Criados"),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildEventList(eventosInscritos, isCriados: false),
                buildEventList(eventosCriados, isCriados: true),
              ],
            ),
    );
  }
}
