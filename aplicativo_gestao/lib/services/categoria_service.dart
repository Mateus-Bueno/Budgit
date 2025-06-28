import '../models/categoria.dart';

abstract class CategoriaService {
  Future<List<Categoria>> fetchCategorias();
  Future<void> addCategoria(Categoria categoria);
  Future<void> updateCategoria(Categoria categoria);
  Future<void> deleteCategoria(int id);
}
