import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2_andre/models/Veiculo.dart';

class VeiculoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collectionRef {
    // coleção raiz "veiculos"
    return _db.collection('veiculos');
  }

  /// CREATE ou UPDATE (se id for passado)
  Future<void> salvarVeiculo({
    String? id,
    required String modelo,
    required String marca,
    required String placa,
    required int ano,
    required String tipoCombustivel,
  }) async {
    final data = {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
      'atualizadoEm': FieldValue.serverTimestamp(),
    };

    if (id == null) {
      await _collectionRef.add({
        ...data,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    } else {
      await _collectionRef.doc(id).update(data);
    }
  }

  /// READ – stream de lista de veículos
  Stream<List<Veiculo>> streamVeiculos() {
    return _collectionRef
        .orderBy('modelo')
        .snapshots()
        .map((query) {
      return query.docs
          .map(
            (doc) => Veiculo.fromMap(doc.id, doc.data()),
          )
          .toList();
    });
  }

  /// DELETE
  Future<void> deletarVeiculo(String id) async {
    await _collectionRef.doc(id).delete();
  }
}
