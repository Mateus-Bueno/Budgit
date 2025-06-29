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

  Widget _blocoAnalise() {
    final variacao = totalAnterior > 0 ? ((totalAtual - totalAnterior) / totalAnterior) * 100 : null;
    final corVar = variacao != null
        ? (variacao >= 0 ? Colors.green[700] : Colors.red[700])
        : Theme.of(context).textTheme.bodyMedium?.color;
    final sinal = variacao != null ? (variacao >= 0 ? '+' : '') : '';
    final variacaoTexto = variacao != null
        ? '$sinal${variacao.toStringAsFixed(1)}%'
        : 'sem comparação';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total gasto neste mês',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Text(
                'R\$ ${totalAtual.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              SizedBox(height: 8),
              Text('Variação mensal:',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                variacaoTexto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: corVar,
                ),
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _infoCard(
              title: 'Maior Gasto',
              content: nomeCategoriaMaior,
              subtitle: 'R\$ ${valorCategoriaMaior.toStringAsFixed(2)}',
            ),
            _infoCard(
              title: 'Maior Aumento',
              content: categoriaMaiorAumento ?? 'N/A',
              subtitle: crescimento != null
                  ? '+${crescimento!.toStringAsFixed(1)}%'
                  : 'sem dados',
              subtitleColor: Colors.deepOrange[700],
            ),
            _infoCard(
              title: 'Transações',
              content: '$qtdTransacoes',
              subtitle: 'neste mês',
            ),
            _infoCard(
              title: 'Gasto mês anterior',
              content: 'R\$ ${totalAnterior.toStringAsFixed(2)}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoCard({
    required String title,
    required String content,
    String? subtitle,
    Color? subtitleColor,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
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
