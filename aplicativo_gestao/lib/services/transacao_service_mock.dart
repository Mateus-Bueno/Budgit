import 'dart:async';
import '../models/transacao.dart';
import 'transacao_service.dart';

class TransacaoServiceMock implements TransacaoService {
  final List<Transacao> _transacoes = [
  // MÊS ATUAL
  Transacao(id: 1, valor: 45.00, data: '2025-06-02', descricao: 'Supermercado', userId: 1, categoriaId: 1),
  Transacao(id: 2, valor: 20.00, data: '2025-06-03', descricao: 'Uber', userId: 1, categoriaId: 2),
  Transacao(id: 3, valor: 80.00, data: '2025-06-05', descricao: 'Cinema', userId: 1, categoriaId: 3),
  Transacao(id: 4, valor: 120.00, data: '2025-06-06', descricao: 'Farmácia', userId: 2, categoriaId: 4),
  Transacao(id: 5, valor: 35.00, data: '2025-06-07', descricao: 'Livro de economia', userId: 2, categoriaId: 5),
  Transacao(id: 6, valor: 60.00, data: '2025-06-09', descricao: 'Restaurante', userId: 1, categoriaId: 1),
  Transacao(id: 7, valor: 22.00, data: '2025-06-10', descricao: 'Ônibus', userId: 1, categoriaId: 2),
  Transacao(id: 8, valor: 45.00, data: '2025-06-12', descricao: 'Sorvete com amigos', userId: 2, categoriaId: 3),
  Transacao(id: 9, valor: 95.00, data: '2025-06-15', descricao: 'Consulta médica', userId: 1, categoriaId: 4),
  Transacao(id: 10, valor: 29.90, data: '2025-06-17', descricao: 'E-book', userId: 2, categoriaId: 5),

  // MÊS PASSADO
  Transacao(id: 11, valor: 42.00, data: '2025-05-01', descricao: 'Mercado', userId: 1, categoriaId: 1),
  Transacao(id: 12, valor: 18.00, data: '2025-05-02', descricao: 'Gasolina', userId: 2, categoriaId: 2),
  Transacao(id: 13, valor: 60.00, data: '2025-05-04', descricao: 'Barzinho', userId: 1, categoriaId: 3),
  Transacao(id: 14, valor: 110.00, data: '2025-05-06', descricao: 'Consulta oftalmológica', userId: 1, categoriaId: 4),
  Transacao(id: 15, valor: 32.00, data: '2025-05-08', descricao: 'Apostila', userId: 2, categoriaId: 5),
  Transacao(id: 16, valor: 52.00, data: '2025-05-10', descricao: 'Restaurante', userId: 1, categoriaId: 1),
  Transacao(id: 17, valor: 16.00, data: '2025-05-11', descricao: 'Uber', userId: 1, categoriaId: 2),
  Transacao(id: 18, valor: 70.00, data: '2025-05-13', descricao: 'Parque de diversões', userId: 1, categoriaId: 3),
  Transacao(id: 19, valor: 130.00, data: '2025-05-14', descricao: 'Exames', userId: 2, categoriaId: 4),
  Transacao(id: 20, valor: 25.00, data: '2025-05-16', descricao: 'Curso online', userId: 2, categoriaId: 5),

  // 2 MESES ATRÁS
  Transacao(id: 21, valor: 37.00, data: '2025-04-01', descricao: 'Feira', userId: 1, categoriaId: 1),
  Transacao(id: 22, valor: 25.00, data: '2025-04-03', descricao: 'Ônibus', userId: 1, categoriaId: 2),
  Transacao(id: 23, valor: 55.00, data: '2025-04-05', descricao: 'Cinema', userId: 2, categoriaId: 3),
  Transacao(id: 24, valor: 100.00, data: '2025-04-07', descricao: 'Dentista', userId: 1, categoriaId: 4),
  Transacao(id: 25, valor: 40.00, data: '2025-04-09', descricao: 'Livros', userId: 2, categoriaId: 5),
  Transacao(id: 26, valor: 65.00, data: '2025-04-11', descricao: 'Almoço fora', userId: 1, categoriaId: 1),
  Transacao(id: 27, valor: 20.00, data: '2025-04-13', descricao: 'Gasolina', userId: 1, categoriaId: 2),
  Transacao(id: 28, valor: 90.00, data: '2025-04-15', descricao: 'Show', userId: 1, categoriaId: 3),
  Transacao(id: 29, valor: 85.00, data: '2025-04-17', descricao: 'Farmácia', userId: 2, categoriaId: 4),
  Transacao(id: 30, valor: 28.00, data: '2025-04-19', descricao: 'Curso gratuito (material)', userId: 2, categoriaId: 5),
];


  @override
  Future<List<Transacao>> fetchTransacoes() async {
    await Future.delayed(Duration(milliseconds: 300));
    return List.from(_transacoes);
  }

  @override
  Future<void> addTransacao(Transacao transacao) async {
    final novoId = _transacoes.isEmpty ? 1 : _transacoes.last.id! + 1;
    _transacoes.add(Transacao(
      id: novoId,
      valor: transacao.valor,
      data: transacao.data,
      descricao: transacao.descricao,
      userId: transacao.userId,
      categoriaId: transacao.categoriaId,
    ));
  }

  @override
  Future<void> updateTransacao(Transacao transacao) async {
    final index = _transacoes.indexWhere((t) => t.id == transacao.id);
    if (index != -1) {
      _transacoes[index] = transacao;
    }
  }

  @override
  Future<void> deleteTransacao(int id) async {
    _transacoes.removeWhere((t) => t.id == id);
  }
}

