import '../models/usuario.dart';

abstract class UsuarioService {
  Future<List<Usuario>> fetchUsuarios();
  Future<void> addUsuario(Usuario usuario);
  Future<void> updateUsuario(Usuario usuario);
  Future<void> deleteUsuario(int id);

}
