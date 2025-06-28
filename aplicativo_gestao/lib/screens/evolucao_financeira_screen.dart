import 'package:flutter/material.dart';
import '../app_config.dart';
import '../models/categoria.dart';
import '../models/usuario.dart';

class EvolucaoFinanceiraScreen extends StatefulWidget {
  @override
  _EvolucaoFinanceiraScreenState createState() => _EvolucaoFinanceiraScreenState();
}

class _EvolucaoFinanceiraScreenState extends State<EvolucaoFinanceiraScreen> {
  List<Usuario> usuarios = [];
  int? usuarioSelecionado;
  bool carregando = true;

  late double totalAtual;
  late double totalAnterior;
  late String nomeCategoriaMaior;
  late double valorCategoriaMaior;
  late String? categoriaMaiorAumento;
  late double? crescimento;
  late int qtdTransacoes;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    final lista = await AppConfig.getUsuarioService().fetchUsuarios();
    if (!mounted) return;
    setState(() {
      usuarios = lista;
      usuarioSelecionado = null;
    });
    _gerarAnalises();
  }

  Future<void> _gerarAnalises() async {
    if (!mounted) return;
    setState(() => carregando = true);

    final transacoes = await AppConfig.getTransacaoService().fetchTransacoes();
    final categorias = await AppConfig.getCategoriaService().fetchCategorias();

    final now = DateTime.now();
    final mesAtual = DateTime(now.year, now.month);
    final mesAnterior = DateTime(now.year, now.month - 1);

    totalAtual = 0;
    totalAnterior = 0;
    Map<int, double> atualPorCategoria = {};
    Map<int, double> anteriorPorCategoria = {};

    for (var t in transacoes) {
      if (usuarioSelecionado != null && t.userId != usuarioSelecionado) continue;
      final data = DateTime.tryParse(t.data);
      if (data == null) continue;

      if (data.year == mesAtual.year && data.month == mesAtual.month) {
        totalAtual += t.valor;
        atualPorCategoria[t.categoriaId] = (atualPorCategoria[t.categoriaId] ?? 0) + t.valor;
      } else if (data.year == mesAnterior.year && data.month == mesAnterior.month) {
        totalAnterior += t.valor;
        anteriorPorCategoria[t.categoriaId] = (anteriorPorCategoria[t.categoriaId] ?? 0) + t.valor;
      }
    }

    int? idMaiorCat;
    double maiorValor = 0;
    atualPorCategoria.forEach((id, valor) {
      if (valor > maiorValor) {
        maiorValor = valor;
        idMaiorCat = id;
      }
    });

    nomeCategoriaMaior = categorias
        .firstWhere((c) => c.id == idMaiorCat, orElse: () => Categoria(id: 0, nome: 'Desconhecida'))
        .nome;
    valorCategoriaMaior = maiorValor;

    categoriaMaiorAumento = null;
    crescimento = null;
    double maiorCresc = -double.infinity;

    for (var id in atualPorCategoria.keys) {
      final atual = atualPorCategoria[id]!;
      final anterior = anteriorPorCategoria[id] ?? 0;
      if (anterior > 0) {
        final variacao = ((atual - anterior) / anterior) * 100;
        if (variacao > maiorCresc) {
          maiorCresc = variacao;
          categoriaMaiorAumento = categorias.firstWhere((c) => c.id == id).nome;
          crescimento = variacao;
        }
      }
    }

    qtdTransacoes = transacoes
        .where((t) {
          if (usuarioSelecionado != null && t.userId != usuarioSelecionado) return false;
          final data = DateTime.tryParse(t.data);
          return data != null && data.year == mesAtual.year && data.month == mesAtual.month;
        })
        .length;

    if (!mounted) return;
    setState(() => carregando = false);
  }

  Widget _valorTexto(String label, String valor,
      {Color? cor = Colors.black, double tamanho = 16, bool negrito = false}) {
    return Text.rich(
      TextSpan(
        text: '$label ',
        style: TextStyle(fontSize: tamanho),
        children: [
          TextSpan(
            text: valor,
            style: TextStyle(
              fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
              color: cor ?? Colors.black,
              fontSize: tamanho + 1,
            ),
          )
        ],
      ),
    );
  }

  Widget _blocoAnalise() {
    final variacao = totalAnterior > 0 ? ((totalAtual - totalAnterior) / totalAnterior) * 100 : null;
    final corVar = variacao != null
        ? (variacao >= 0 ? Colors.green[700] : Colors.red[700])
        : null;
    final sinal = variacao != null ? (variacao >= 0 ? '+' : '') : '';
    final variacaoTexto =
        variacao != null ? '$sinal${variacao.toStringAsFixed(1)}%' : 'sem comparação';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _valorTexto('Este mês você gastou um total de',
            'R\$ ${totalAtual.toStringAsFixed(2)}', tamanho: 18, negrito: true),
        SizedBox(height: 12),
        _valorTexto('Variação em relação ao mês anterior:', variacaoTexto,
            cor: corVar, tamanho: 16, negrito: true),
        SizedBox(height: 16),
        Text.rich(
          TextSpan(
            text: 'Maior categoria de gasto: ',
            style: TextStyle(fontSize: 16),
            children: [
              TextSpan(
                text: nomeCategoriaMaior,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              TextSpan(
                text: ' (R\$ ${valorCategoriaMaior.toStringAsFixed(2)})',
              ),
            ],
          ),
        ),
        if (categoriaMaiorAumento != null && crescimento != null) ...[
          SizedBox(height: 12),
          Text.rich(
            TextSpan(
              text: 'Categoria com maior aumento: ',
              style: TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: categoriaMaiorAumento!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.deepOrange[700],
                  ),
                ),
                TextSpan(
                  text: ' (+${crescimento!.toStringAsFixed(1)}%)',
                  style: TextStyle(color: Colors.deepOrange[700]),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 16),
        _valorTexto('Transações realizadas neste mês:', '$qtdTransacoes'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return carregando
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Pessoa: '),
                    SizedBox(width: 8),
                    DropdownButton<int?>(
                      value: usuarioSelecionado,
                      onChanged: (value) {
                        setState(() => usuarioSelecionado = value);
                        _gerarAnalises();
                      },
                      items: [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        ...usuarios.map((u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.nome),
                            )),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _blocoAnalise(),
              ],
            ),
          );
  }
}
