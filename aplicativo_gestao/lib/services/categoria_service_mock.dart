import 'dart:async';
import '../models/categoria.dart';
import 'categoria_service.dart';

class CategoriaServiceMock implements CategoriaService {
  final List<Categoria> _categorias = [
    Categoria(id: 1, nome: 'Alimentação', descricao: 'Comida e mercado'),
    Categoria(id: 2, nome: 'Transporte', descricao: 'Uber, ônibus, gasolina'),
    Categoria(id: 3, nome: 'Lazer', descricao: 'Cinema, passeios'),
    Categoria(id: 4, nome: 'Saúde', descricao: 'Farmácia, consultas'),
    Categoria(id: 5, nome: 'Educação', descricao: 'Cursos e livros'),
  ];

  @override
  Future<List<Categoria>> fetchCategorias() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_categorias); // retorna cópia
  }

  @override
  Future<void> addCategoria(Categoria categoria) async {
    final novoId = (_categorias.isEmpty ? 1 : _categorias.last.id! + 1);
    final novaCategoria = Categoria(
      id: novoId,
      nome: categoria.nome,
      descricao: categoria.descricao,
    );
    _categorias.add(novaCategoria);
  }

  @override
  Future<void> updateCategoria(Categoria categoria) async {
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index != -1) {
      _categorias[index] = categoria;
    }
  }

  @override
  Future<void> deleteCategoria(int id) async {
    _categorias.removeWhere((c) => c.id == id);
  }
}
