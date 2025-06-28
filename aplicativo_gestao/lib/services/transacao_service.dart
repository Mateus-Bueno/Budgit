import '../models/transacao.dart';

abstract class TransacaoService {
  Future<List<Transacao>> fetchTransacoes();
  Future<void> addTransacao(Transacao transacao);
  Future<void> updateTransacao(Transacao transacao);
  Future<void> deleteTransacao(int id);
}
