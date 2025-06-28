import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../app_config.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? categoria;

  CategoriaFormScreen({this.categoria});

  @override
  _CategoriaFormScreenState createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String nome;
  late String descricao;

  @override
  void initState() {
    super.initState();
    nome = widget.categoria?.nome ?? '';
    descricao = widget.categoria?.descricao ?? '';
  }

  void _salvar() async {
    if (_formKey.currentState!.validate()) {
      final novaCategoria = Categoria(
        id: widget.categoria?.id,
        nome: nome,
        descricao: descricao,
      );

      final service = AppConfig.getCategoriaService();

      if (widget.categoria == null) {
        await service.addCategoria(novaCategoria);
      } else {
        await service.updateCategoria(novaCategoria);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: nome,
                decoration: InputDecoration(labelText: 'Nome'),
                onChanged: (value) => nome = value,
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                initialValue: descricao,
                decoration: InputDecoration(labelText: 'Descrição'),
                onChanged: (value) => descricao = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
