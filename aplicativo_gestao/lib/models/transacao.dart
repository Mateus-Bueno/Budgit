class Transacao {
  final int? id;
  final double valor;
  final String data; // sempre em formato "yyyy-MM-dd"
  final String descricao;
  final int userId;
  final int categoriaId;

  Transacao({
    this.id,
    required this.valor,
    required this.data,
    required this.descricao,
    required this.userId,
    required this.categoriaId,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) {
    // Converte a data do formato [2025, 6, 30] para "2025-06-30"
    String dataFormatada;
    if (json['data'] is List && json['data'].length >= 3) {
      final d = json['data'];
      dataFormatada =
          '${d[0].toString().padLeft(4, '0')}-${d[1].toString().padLeft(2, '0')}-${d[2].toString().padLeft(2, '0')}';
    } else if (json['data'] is String) {
      dataFormatada = json['data'];
    } else {
      dataFormatada = '';
    }

    return Transacao(
      id: json['id'],
      valor: (json['valor'] as num).toDouble(),
      data: dataFormatada,
      descricao: json['descricao'],
      userId: json['userId'],
      categoriaId: json['categoriaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'valor': valor,
      'data': data,
      'descricao': descricao,
      'userId': userId,
      'categoriaId': categoriaId,
    };
  }
}
