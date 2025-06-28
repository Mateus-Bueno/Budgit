import 'services/categoria_service.dart';
import 'services/categoria_service_mock.dart';
import 'services/categoria_service_http.dart';

import 'services/transacao_service.dart';
import 'services/transacao_service_mock.dart';
import 'services/transacao_service_http.dart';

import 'services/usuario_service.dart';
import 'services/usuario_service_mock.dart';
import 'services/usuario_service_http.dart';

enum Ambiente { mock, producao }

class AppConfig {
  static const Ambiente ambiente = Ambiente.mock;

  // Instâncias únicas (singleton)
  static final CategoriaService _categoriaService =
      ambiente == Ambiente.producao
          ? CategoriaServiceHttp()
          : CategoriaServiceMock();

  static final TransacaoService _transacaoService =
      ambiente == Ambiente.producao
          ? TransacaoServiceHttp()
          : TransacaoServiceMock();

  static final UsuarioService _usuarioService =
      ambiente == Ambiente.producao
          ? UsuarioServiceHttp()
          : UsuarioServiceMock();

  static CategoriaService getCategoriaService() => _categoriaService;
  static TransacaoService getTransacaoService() => _transacaoService;
  static UsuarioService getUsuarioService() => _usuarioService;
}
