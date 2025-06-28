class Transacao {
  final int? id;
  final double valor;
  final String data;
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
    return Transacao(
      id: json['id'],
      valor: json['valor'].toDouble(),
      data: json['data'],
      descricao: json['descricao'],
      userId: json['userId'],
      categoriaId: json['categoriaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valor': valor,
      'data': data,
      'descricao': descricao,
      'userId': userId,
      'categoriaId': categoriaId,
    };
  }
}
