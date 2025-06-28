import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transacao.dart';
import 'transacao_service.dart';

class TransacaoServiceHttp implements TransacaoService {
  final String baseUrl = 'http://localhost:8080/transacoes';

  @override
  Future<void> addTransacao(Transacao transacao) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transacao.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
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
      throw Exception('Erro ao atualizar transação');
    }
  }


  @override
  Future<List<Transacao>> fetchTransacoes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Transacao.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar transações');
    }
  }

  @override
  Future<void> deleteTransacao(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar transação');
    }
  }

}
