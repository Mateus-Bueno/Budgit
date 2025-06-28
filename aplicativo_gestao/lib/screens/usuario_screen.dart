import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../app_config.dart';
import 'usuario_form_screen.dart';

class UsuarioScreen extends StatefulWidget {
  @override
  _UsuarioScreenState createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  late Future<List<Usuario>> usuarios;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    setState(() {
      usuarios = AppConfig.getUsuarioService().fetchUsuarios();
    });
  }

  Future<void> _deletarUsuario(int id) async {
    await AppConfig.getUsuarioService().deleteUsuario(id);
    _carregarUsuarios();
  }

  void _abrirFormulario({Usuario? usuario}) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsuarioFormScreen(usuario: usuario),
      ),
    );
    if (resultado == true) {
      _carregarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuários na Família'),
      ),
      body: FutureBuilder<List<Usuario>>(
        future: usuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum usuário encontrado.'));
          } else {
            final lista = snapshot.data!;
            return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                final user = lista[index];
                return ListTile(
                  title: Text(user.nome),
                  subtitle: Text(user.email),
                  onTap: () => _abrirFormulario(usuario: user),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Excluir usuário?'),
                          content: Text('Deseja remover "${user.nome}"?'),
                          actions: [
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text('Excluir'),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _deletarUsuario(user.id!);
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        tooltip: 'Adicionar Usuário',
        child: Icon(Icons.add),
      ),
    );
  }
}
