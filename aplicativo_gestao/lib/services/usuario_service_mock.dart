import 'dart:async';
import '../models/usuario.dart';
import 'usuario_service.dart';

class UsuarioServiceMock implements UsuarioService {
  final List<Usuario> _usuarios = [
    Usuario(id: 1, nome: 'Ana', email: 'ana@email.com', senha: '123'),
    Usuario(id: 2, nome: 'Gabriela', email: 'gabriela@email.com', senha: '456'),
    Usuario(id: 3, nome: 'Jhonatan', email: 'jhonatan@email.com', senha: '789'),
    Usuario(id: 4, nome: 'Letícia', email: 'leticia@email.com', senha: '000'),
    Usuario(id: 5, nome: 'Mateus', email: 'mateus@email.com', senha: '111'),
  ];

  @override
  Future<List<Usuario>> fetchUsuarios() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_usuarios);
  }

  @override
  Future<void> addUsuario(Usuario usuario) async {
    final novoId = _usuarios.isEmpty ? 1 : _usuarios.last.id! + 1;
    _usuarios.add(Usuario(
      id: novoId,
      nome: usuario.nome,
      email: usuario.email,
      senha: usuario.senha,
    ));
  }

  @override
  Future<void> updateUsuario(Usuario usuario) async {
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _usuarios[index] = usuario;
    }
  }

  @override
  Future<void> deleteUsuario(int id) async {
    _usuarios.removeWhere((u) => u.id == id);
  }
}
