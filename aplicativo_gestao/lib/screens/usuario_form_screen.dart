import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../app_config.dart';

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  UsuarioFormScreen({this.usuario});

  @override
  _UsuarioFormScreenState createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late String email;
  late String senha;

  @override
  void initState() {
    super.initState();
    nome = widget.usuario?.nome ?? '';
    email = widget.usuario?.email ?? '';
    senha = widget.usuario?.senha ?? '';
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novoUsuario = Usuario(
        id: widget.usuario?.id,
        nome: nome,
        email: email,
        senha: senha,
      );

      final service = AppConfig.getUsuarioService();

      if (widget.usuario == null) {
        await service.addUsuario(novoUsuario);
      } else {
        await service.updateUsuario(novoUsuario);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuario == null ? 'Novo Usuário' : 'Editar Usuário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: nome,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (v) => nome = v,
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v,
                validator: (v) => v == null || v.isEmpty ? 'Informe o email' : null,
              ),
              TextFormField(
                initialValue: senha,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                onChanged: (v) => senha = v,
                validator: (v) => v == null || v.isEmpty ? 'Informe a senha' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
