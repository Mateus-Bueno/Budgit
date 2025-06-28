import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../app_config.dart';
import 'categoria_form_screen.dart';

class CategoriaScreen extends StatefulWidget {
  @override
  _CategoriaScreenState createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  late Future<List<Categoria>> categorias;

  @override
  void initState() {
    super.initState();
    categorias = AppConfig.getCategoriaService().fetchCategorias();
  }

  void _atualizarCategorias() {
    setState(() {
      categorias = AppConfig.getCategoriaService().fetchCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categorias')),
      body: FutureBuilder<List<Categoria>>(
        future: categorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma categoria encontrada.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cat = snapshot.data![index];
                return ListTile(
                  title: Text(cat.nome),
                  subtitle: Text(cat.descricao ?? '-'),
                  onTap: () async {
                    final atualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoriaFormScreen(categoria: cat),
                      ),
                    );
                    if (atualizado == true) {
                      _atualizarCategorias();
                    }
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Excluir categoria?'),
                          content: Text('Deseja remover "${cat.nome}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Excluir')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await AppConfig.getCategoriaService().deleteCategoria(cat.id!);
                        _atualizarCategorias();
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
        onPressed: () async {
          final criado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoriaFormScreen()),
          );
          if (criado == true) {
            _atualizarCategorias();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
