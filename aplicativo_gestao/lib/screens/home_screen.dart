import 'package:flutter/material.dart';
import 'transacao_screen.dart';
import 'dashboard_screen.dart';
import 'evolucao_financeira_screen.dart';
import 'configuracoes_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TransacaoScreen(),
    DashboardScreen(),
    EvolucaoFinanceiraScreen(),
  ];

  final List<String> _titles = [
    'Transações',
    'Gráfico de Gastos',
    'Evolução Financeira',
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.monetization_on),
      label: 'Transações',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart),
      label: 'Gráfico',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.trending_up),
      label: 'Evolução',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _abrirConfiguracoes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfiguracoesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () => _abrirConfiguracoes(context),
          )
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
