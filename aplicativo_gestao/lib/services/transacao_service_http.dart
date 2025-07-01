import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transacao.dart';
import 'transacao_service.dart';

class TransacaoServiceHttp implements TransacaoService {
  final String baseUrl = 'https://transacoes-api-production.up.railway.app/transacoes';

  @override
  Future<void> addTransacao(Transacao transacao) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transacao.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Erro ao criar transação: ${response.body}');
      throw Exception('Erro ao criar transação');
    }
  }

  @override
  Future<void> updateTransacao(Transacao transacao) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${transacao.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transacao.toJson()),
    );

    if (response.statusCode != 200) {
      print('Erro ao atualizar transação: ${response.body}');
      throw Exception('Erro ao atualizar transação');
    }
  }

  @override
  Future<List<Transacao>> fetchTransacoes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List jsonData = jsonDecode(response.body);
        print('Transações recebidas: $jsonData');

        return jsonData.map((e) => Transacao.fromJson(e)).toList();
      } else {
        print('Erro status ${response.statusCode}: ${response.body}');
        throw Exception('Erro ao carregar transações');
      }
    } catch (e) {
      print('Erro em fetchTransacoes: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTransacao(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      print('Erro ao deletar transação: ${response.body}');
      throw Exception('Erro ao deletar transação');
    }
  }
}
