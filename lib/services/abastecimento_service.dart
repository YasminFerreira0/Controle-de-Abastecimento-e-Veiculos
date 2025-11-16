import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2_andre/models/Abastecimento.dart';

class AbastecimentoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collectionRef =>
      _db.collection('abastecimentos');

  /// CREATE ou UPDATE
  Future<void> salvarAbastecimento({
    String? id,
    required DateTime data,
    required double quantidadeLitros,
    required double valorPago,
    required int quilometragem,
    required String tipoCombustivel,
    required String veiculoId,
    required double consumo,
    String? observacao,
  }) async {
    final dataMap = {
      'data': Timestamp.fromDate(data),
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'veiculoId': veiculoId,
      'consumo': consumo,
      'observacao': observacao,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (id == null) {
      await _collectionRef.add({
        ...dataMap,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } else {
      await _collectionRef.doc(id).update(dataMap);
    }
  }

  /// LIST – todos os abastecimentos (pode filtrar por veiculoId se quiser)
  Stream<List<Abastecimento>> streamAbastecimentos({String? veiculoId}) {
    Query<Map<String, dynamic>> query = _collectionRef.orderBy(
      'data',
      descending: true,
    );

    if (veiculoId != null) {
      query = query.where('veiculoId', isEqualTo: veiculoId);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Abastecimento.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// DELETE
  Future<void> deletarAbastecimento(String id) async {
    await _collectionRef.doc(id).delete();
  }
}
