// LoginPage.dart
import 'package:flutter/material.dart';
import 'home.dart'; // Importa a HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // Aqui você pode adicionar a lógica para autenticação real
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login bem-sucedido!')));

      // Redireciona para a HomePage após o login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ), // Navega para a HomePage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(6, 32, 43, 1),
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Campo de email
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      fillColor: const Color.fromRGBO(245, 238, 221, 1),
                      filled: true,
                      labelText: 'Email',
                      hintText: 'Digite seu email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um email';
                      }
                      if (!RegExp(
                        r"^[a-zA-Z0-9]+@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]{2,}$",
                      ).hasMatch(value)) {
                        return 'Digite um email válido';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                // Campo de senha
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      fillColor: const Color.fromRGBO(245, 238, 221, 1),
                      filled: true,
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),
                // Botão de login
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Entrar'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
