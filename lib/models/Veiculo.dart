class Veiculo {
  final String id;           // ID do documento no Firestore
  final String modelo;
  final String marca;
  final String placa;
  final int ano;
  final String tipoCombustivel;

  Veiculo({
    required this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
    };
  }

  factory Veiculo.fromMap(String id, Map<String, dynamic> map) {
    return Veiculo(
      id: id,
      modelo: map['modelo'] ?? '',
      marca: map['marca'] ?? '',
      placa: map['placa'] ?? '',
      ano: (map['ano'] ?? 0) is int
          ? map['ano']
          : int.tryParse(map['ano'].toString()) ?? 0,
      tipoCombustivel: map['tipoCombustivel'] ?? '',
    );
  }
}
