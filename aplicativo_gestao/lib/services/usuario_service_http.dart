import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'usuario_service.dart';

class UsuarioServiceHttp implements UsuarioService {
  final String baseUrl = 'http://localhost:8080/usuarios';

  @override
  Future<List<Usuario>> fetchUsuarios() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Usuario.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar usuários');
    }
  }

  @override
  Future<void> addUsuario(Usuario usuario) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar usuário');
    }
  }

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${usuario.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar usuário');
    }
  }

  @override
  Future<void> deleteUsuario(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar usuário');
    }
  }
}
