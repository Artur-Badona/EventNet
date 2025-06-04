import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;



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

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _imagemController = TextEditingController();
  final _maxInscricoesController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _idCategoriaController = TextEditingController();
  
  List<Categoria> _categorias = [];
  Categoria? _categoriaSelecionada;

  DateTime? _dataInicioInscricao;
  DateTime? _dataFimInscricao;
  DateTime? _dataEvento;

  File? _imagemSelecionada;


  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  Future<String?> uploadImagem(File imagem) async {
    final uri = Uri.parse('http://10.0.2.2:8000/upload-image/');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', imagem.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);
      return "http://10.0.2.2:8000${data['url']}";
    } else {
      print('Erro no upload da imagem: ${response.statusCode}');
      return null;
    }
  }

  Future<void> selecionarImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }


  Future<void> _carregarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/categorias'),
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _categorias = data.map((e) => Categoria.fromJson(e)).toList();
      });
    } else {
      print('Erro ao carregar categorias: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<bool> criarEvento(String token) async {
    final url = Uri.parse('http://10.0.2.2:8000/evento');

    final body = jsonEncode({
      "titulo": _tituloController.text,
      "descricao": _descricaoController.text,
      "data_inicio_inscricao": _dataInicioInscricao != null
          ? _dataInicioInscricao!.toIso8601String().substring(0, 10)
          : null,
      "data_fim_inscricao": _dataFimInscricao != null
          ? _dataFimInscricao!.toIso8601String().substring(0, 10)
          : null,
      "data_evento": _dataEvento?.toUtc().toIso8601String(),
      "imagem": _imagemSelecionada != null ? await uploadImagem(_imagemSelecionada!) : _imagemController.text,
      "maximo_inscricoes": int.tryParse(_maxInscricoesController.text) ?? 0,
      "localizacao": _localizacaoController.text,
      "id_categoria": _categoriaSelecionada?.id ?? 0,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print('Erro: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<void> _selectDataInicioInscricao() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataInicioInscricao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataInicioInscricao = picked;
      });
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _selectDataFimInscricao() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataFimInscricao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataFimInscricao = picked;
      });
    }
  }

  Future<void> _selectDataEvento() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dataEvento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _dataEvento != null
            ? TimeOfDay(hour: _dataEvento!.hour, minute: _dataEvento!.minute)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _dataEvento = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_dataInicioInscricao == null ||
          _dataFimInscricao == null ||
          _dataEvento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, preencha todas as datas')),
        );
        return;
      }

      final token = await getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      bool sucesso = await criarEvento(token);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Evento criado com sucesso!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar evento')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Evento'),
        backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe o título' : null,
              ),

              // Descrição
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a descrição' : null,
              ),

             
              SizedBox(height: 16),
              Text('Data início da inscrição'),
              TextButton(
                onPressed: _selectDataInicioInscricao,
                child: Text(_dataInicioInscricao == null
                    ? 'Selecione a data'
                    : _dateFormat.format(_dataInicioInscricao!)),
              ),

            
              SizedBox(height: 16),
              Text('Data fim da inscrição'),
              TextButton(
                onPressed: _selectDataFimInscricao,
                child: Text(_dataFimInscricao == null
                    ? 'Selecione a data'
                    : _dateFormat.format(_dataFimInscricao!)),
              ),

             
              SizedBox(height: 16),
              Text('Data e hora do evento'),
              TextButton(
                onPressed: _selectDataEvento,
                child: Text(_dataEvento == null
                    ? 'Selecione data e hora'
                    : _dateTimeFormat.format(_dataEvento!)),
              ),

              
              Text('Imagem do Evento'),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: selecionarImagem,
                  icon: Icon(Icons.image),
                  label: Text('Selecionar imagem'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(7, 122, 125, 1),
                  ),
                ),
              ),
              SizedBox(height: 8),
              if (_imagemSelecionada != null) 
                Center(
                  child: Column(
                    children: [
                      Image.file(
                        _imagemSelecionada!,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        path.basename(_imagemSelecionada!.path),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

             
              TextFormField(
                controller: _maxInscricoesController,
                decoration: InputDecoration(labelText: 'Máximo de inscrições'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o máximo';
                  if (int.tryParse(v) == null) return 'Informe um número válido';
                  return null;
                },
              ),

             
              TextFormField(
                controller: _localizacaoController,
                decoration: InputDecoration(labelText: 'Localização'),
              ),

              
              DropdownButtonFormField<Categoria>(
                decoration: InputDecoration(labelText: 'Categoria'),
                value: _categoriaSelecionada,
                items: _categorias
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.nome),
                        ))
                    .toList(),
                onChanged: (categoria) {
                  setState(() {
                    _categoriaSelecionada = categoria;
                  });
                },
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),

              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                child: Text('Criar Evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(7, 122, 125, 1),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
