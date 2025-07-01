import 'package:flutter/material.dart';
import '../models/transacao.dart';
import '../models/categoria.dart';
import '../app_config.dart';
import 'transacao_form_screen.dart';

class TransacaoScreen extends StatefulWidget {
  @override
  _TransacaoScreenState createState() => _TransacaoScreenState();
}

class _TransacaoScreenState extends State<TransacaoScreen> {
  List<Transacao> transacoes = [];
  List<Categoria> categorias = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final t = await AppConfig.getTransacaoService().fetchTransacoes();
    final c = await AppConfig.getCategoriaService().fetchCategorias();

    // Ordenar por data decrescente
    t.sort((a, b) => DateTime.parse(b.data).compareTo(DateTime.parse(a.data)));

    if (!mounted) return;
    setState(() {
      transacoes = t;
      categorias = c;
    });
  }

  String _nomeCategoria(int id) {
    return categorias.firstWhere((c) => c.id == id, orElse: () => Categoria(id: 0, nome: 'Desconhecida')).nome;
  }

  void _editar(Transacao t) async {
    final atualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransacaoFormScreen(transacao: t)),
    );

    if (atualizado == true) _carregarDados();
  }

  void _adicionar() async {
    final criado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TransacaoFormScreen()),
    );

    if (criado == true) _carregarDados();
  }

  void _excluir(int id) async {
    await AppConfig.getTransacaoService().deleteTransacao(id);
    _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: transacoes.isEmpty
          ? Center(child: Text('Nenhuma transação encontrada'))
          : ListView.builder(
              itemCount: transacoes.length,
              itemBuilder: (_, index) {
                final t = transacoes[index];

                String dataFormatada;
                try {
                  final data = DateTime.parse(t.data);
                  dataFormatada =
                      '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
                } catch (_) {
                  dataFormatada = t.data;
                }

                return ListTile(
                  title: Text('R\$ ${t.valor.toStringAsFixed(2)}'),
                  subtitle: Text('${_nomeCategoria(t.categoriaId)} - $dataFormatada'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _excluir(t.id!),
                  ),
                  onTap: () => _editar(t),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionar,
        child: Icon(Icons.add),
        tooltip: 'Adicionar Transação',
      ),
    );
  }
}
