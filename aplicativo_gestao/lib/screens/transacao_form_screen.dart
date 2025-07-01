import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';
import '../models/usuario.dart';
import '../app_config.dart';

class TransacaoFormScreen extends StatefulWidget {
  final Transacao? transacao;

  TransacaoFormScreen({this.transacao});

  @override
  _TransacaoFormScreenState createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late double valor;
  late String descricao;
  late DateTime data;
  int? userId;
  int? categoriaId;

  List<Categoria> categorias = [];
  List<Usuario> usuarios = [];

  @override
  void initState() {
    super.initState();
    final t = widget.transacao;
    valor = t?.valor ?? 0.0;
    descricao = t?.descricao ?? '';

    try {
      data = t != null ? DateTime.parse(t.data) : DateTime.now();
    } catch (_) {
      data = DateTime.now();
    }

    userId = t?.userId;
    categoriaId = t?.categoriaId;

    _carregarOpcoes();
  }

  Future<void> _carregarOpcoes() async {
    final categoriaService = AppConfig.getCategoriaService();
    final usuarioService = AppConfig.getUsuarioService();
    final categoriasCarregadas = await categoriaService.fetchCategorias();
    final usuariosCarregados = await usuarioService.fetchUsuarios();

    final categoriasUnicas = {
      for (var c in categoriasCarregadas) c.id: c
    }.values.toList();

    final usuariosUnicos = {
      for (var u in usuariosCarregados) u.id: u
    }.values.toList();

    setState(() {
      categorias = categoriasUnicas;
      usuarios = usuariosUnicos;
    });
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && categoriaId != null && userId != null) {
      final novaTransacao = Transacao(
        id: widget.transacao?.id,
        valor: valor,
        descricao: descricao,
        data: data.toIso8601String().substring(0, 10),
        userId: userId!,
        categoriaId: categoriaId!,
      );

      final service = AppConfig.getTransacaoService();

      if (widget.transacao == null) {
        await service.addTransacao(novaTransacao);
      } else {
        await service.updateTransacao(novaTransacao);
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _selecionarData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selecionada != null) {
      setState(() => data = selecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transacao == null ? 'Nova Transação' : 'Editar Transação'),
      ),
      body: categorias.isEmpty || usuarios.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: valor == 0.0 ? '' : valor.toString(),
                      decoration: InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.isEmpty ? 'Informe o valor' : null,
                      onChanged: (v) => valor = double.tryParse(v) ?? 0.0,
                    ),
                    TextFormField(
                      initialValue: descricao,
                      decoration: InputDecoration(labelText: 'Descrição'),
                      onChanged: (v) => descricao = v,
                      validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
                    ),
                    ListTile(
                      title: Text('Data: ${data.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _selecionarData,
                    ),
                    DropdownButtonFormField<int>(
                      value: categorias.any((c) => c.id == categoriaId) ? categoriaId : null,
                      decoration: InputDecoration(labelText: 'Categoria'),
                      items: categorias
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.nome)))
                          .toList(),
                      onChanged: (v) => setState(() => categoriaId = v),
                      validator: (v) => v == null ? 'Escolha uma categoria' : null,
                    ),
                    DropdownButtonFormField<int>(
                      value: usuarios.any((u) => u.id == userId) ? userId : null,
                      decoration: InputDecoration(labelText: 'Usuário'),
                      items: usuarios
                          .map((u) => DropdownMenuItem(value: u.id, child: Text(u.nome)))
                          .toList(),
                      onChanged: (v) => setState(() => userId = v),
                      validator: (v) => v == null ? 'Escolha um usuário' : null,
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
