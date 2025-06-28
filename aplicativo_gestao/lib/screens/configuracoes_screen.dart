import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import 'categoria_screen.dart';
import 'usuario_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Modo escuro'),
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
            secondary: Icon(Icons.dark_mode),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Gerenciar Categorias'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => CategoriaScreen(),
              ));
            },
          ),
          ListTile(
            leading: Icon(Icons.family_restroom),
            title: Text('Gerenciar Família'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => UsuarioScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
