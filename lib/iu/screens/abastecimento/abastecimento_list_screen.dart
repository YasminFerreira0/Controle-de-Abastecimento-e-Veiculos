import 'package:flutter/material.dart';
import 'package:p2_andre/models/Abastecimento.dart';

import '../../../services/abastecimento_service.dart';
import 'abastecimento_form_screen.dart';

class AbastecimentosListScreen extends StatelessWidget {
  AbastecimentosListScreen({super.key});

  final _service = AbastecimentoService();

  Future<void> _confirmarExclusao(
      BuildContext context, Abastecimento a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir abastecimento'),
        content: const Text('Tem certeza que deseja excluir este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deletarAbastecimento(a.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento excluído')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  String _formatarData(DateTime data) {
    return data.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_gas_station),
                label: const Text('Novo abastecimento'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AbastecimentoFormScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: StreamBuilder<List<Abastecimento>>(
              stream: _service.streamAbastecimentos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar abastecimentos'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final abastecimentos = snapshot.data!;
                if (abastecimentos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum abastecimento cadastrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: abastecimentos.length,
                  itemBuilder: (context, index) {
                    final a = abastecimentos[index];
                    return ListTile(
                      leading: const Icon(Icons.local_gas_station),
                      title: Text(
                          '${_formatarData(a.data)} • ${a.tipoCombustivel}'),
                      subtitle: Text(
                          'Litros: ${a.quantidadeLitros} • Valor: R\$ ${a.valorPago}\nKm: ${a.quilometragem} • Consumo: ${a.consumo} km/L'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AbastecimentoFormScreen(
                                    abastecimento: a,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmarExclusao(context, a),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
