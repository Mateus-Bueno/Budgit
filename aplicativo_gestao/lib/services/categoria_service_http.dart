import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';
import 'categoria_service.dart';

class CategoriaServiceHttp implements CategoriaService {
  final String baseUrl = 'http://localhost:8083/categories';

  @override
  Future<List<Categoria>> fetchCategorias() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Categoria.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar categorias');
    }
  }

  @override
  Future<void> addCategoria(Categoria categoria) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao criar categoria');
    }
  }

  @override
  Future<void> updateCategoria(Categoria categoria) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${categoria.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar categoria');
    }
  }

  @override
  Future<void> deleteCategoria(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar categoria');
    }
  }
}
