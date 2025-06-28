import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_config.dart';
import '../models/usuario.dart';

enum TipoGrafico { pizza, barras }

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, double> gastosPorCategoria = {};
  double totalGeral = 0.0;
  TipoGrafico tipoGraficoSelecionado = TipoGrafico.pizza;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<Usuario> usuarios = [];
  int? selectedUserId;

  final Map<String, Color> _coresPorCategoria = {};
  final Set<Color> _coresUtilizadas = {};

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
      selectedUserId = lista.isNotEmpty ? lista.first.id : null;
    });
    _carregarDados();
  }

  Color _gerarCorAleatoria() {
    final r = Random();
    Color cor;
    do {
      cor = Color.fromARGB(
        255,
        100 + r.nextInt(156),
        100 + r.nextInt(156),
        100 + r.nextInt(156),
      );
    } while (_coresUtilizadas.contains(cor));
    _coresUtilizadas.add(cor);
    return cor;
  }

  Color _corDaCategoria(String nome) {
    if (!_coresPorCategoria.containsKey(nome)) {
      _coresPorCategoria[nome] = _gerarCorAleatoria();
    }
    return _coresPorCategoria[nome]!;
  }

  Future<void> _carregarDados() async {
    final transacoes = await AppConfig.getTransacaoService().fetchTransacoes();
    final categorias = await AppConfig.getCategoriaService().fetchCategorias();

    final Map<int, String> mapaCategoriaNome = {
      for (var cat in categorias) cat.id!: cat.nome
    };

    final Map<String, double> totais = {};

    for (var t in transacoes) {
      final data = DateTime.tryParse(t.data);
      if (data != null &&
          data.month == selectedMonth &&
          data.year == selectedYear &&
          t.userId == selectedUserId) {
        final nomeCat = mapaCategoriaNome[t.categoriaId] ?? 'Outros';
        totais[nomeCat] = (totais[nomeCat] ?? 0) + t.valor;
      }
    }

    if (!mounted) return;
    setState(() {
      gastosPorCategoria = totais;
      totalGeral = totais.values.fold(0.0, (a, b) => a + b);
    });
  }

  Widget _construirGrafico() {
    final entries = gastosPorCategoria.entries.toList();

    if (tipoGraficoSelecionado == TipoGrafico.pizza) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 400,
          child: PieChart(
            PieChartData(
              sections: List.generate(entries.length, (i) {
                final e = entries[i];
                final percent = (e.value / totalGeral * 100).toStringAsFixed(1);
                return PieChartSectionData(
                  title: '${e.key}\n$percent%',
                  value: e.value,
                  radius: 80,
                  color: _corDaCategoria(e.key),
                  titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                );
              }),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 420,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 11),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= entries.length) return Container();
                      return Text(entries[idx].key, style: TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              barGroups: List.generate(entries.length, (i) {
                final e = entries[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: e.value,
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                      color: _corDaCategoria(e.key),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = gastosPorCategoria.isEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (usuarios.isNotEmpty)
            Row(
              children: [
                Text('Pessoa: '),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: selectedUserId,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedUserId = value);
                      _carregarDados();
                    }
                  },
                  items: usuarios.map((u) {
                    return DropdownMenuItem(
                      value: u.id,
                      child: Text(u.nome),
                    );
                  }).toList(),
                ),
              ],
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Mês: '),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: selectedMonth,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedMonth = value);
                    _carregarDados();
                  }
                },
                items: List.generate(12, (i) {
                  final m = i + 1;
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m.toString().padLeft(2, '0')),
                  );
                }),
              ),
              SizedBox(width: 24),
              Text('Ano: '),
              SizedBox(width: 8),
              DropdownButton<int>(
                value: selectedYear,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedYear = value);
                    _carregarDados();
                  }
                },
                items: List.generate(6, (i) {
                  final y = DateTime.now().year - i;
                  return DropdownMenuItem(value: y, child: Text(y.toString()));
                }),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Tipo de Gráfico: ', style: TextStyle(fontSize: 16)),
              SizedBox(width: 12),
              DropdownButton<TipoGrafico>(
                value: tipoGraficoSelecionado,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => tipoGraficoSelecionado = value);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: TipoGrafico.pizza,
                    child: Text('Pizza'),
                  ),
                  DropdownMenuItem(
                    value: TipoGrafico.barras,
                    child: Text('Barras'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          isEmpty
              ? Center(child: Text('Nenhuma transação para este período.'))
              : Column(
                  children: [
                    _construirGrafico(),
                    SizedBox(height: 24),
                    Text('Totais por Categoria',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 12),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Categoria')),
                        DataColumn(label: Text('Valor (R\$)')),
                        DataColumn(label: Text('%')),
                      ],
                      rows: gastosPorCategoria.entries.map((e) {
                        final percent = (e.value / totalGeral * 100).toStringAsFixed(1);
                        return DataRow(cells: [
                          DataCell(Text(e.key)),
                          DataCell(Text(e.value.toStringAsFixed(2))),
                          DataCell(Text('$percent%')),
                        ]);
                      }).toList(),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
