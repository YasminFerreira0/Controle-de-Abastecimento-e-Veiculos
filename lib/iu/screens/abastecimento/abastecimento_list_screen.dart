import 'package:flutter/material.dart';
import 'package:p2_andre/models/Abastecimento.dart';

import '../../../services/abastecimento_service.dart';
import 'abastecimento_form_screen.dart';

class AbastecimentosListScreen extends StatelessWidget {
  AbastecimentosListScreen({super.key});

  final _service = AbastecimentoService();

  Future<void> _confirmarExclusao(
    BuildContext context,
    Abastecimento a,
  ) async {
    final colors = Theme.of(context).colorScheme;

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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abastecimentos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: colors.onPrimary),
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
                  return const Center(child: CircularProgressIndicator());
                }

                final abastecimentos = snapshot.data!;
                if (abastecimentos.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum abastecimento cadastrado.',
                      style: textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: abastecimentos.length,
                  itemBuilder: (context, index) {
                    final a = abastecimentos[index];

                    return Card(
                      elevation: 1,
                      shadowColor: colors.primary.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),

                        title: Text(
                          '${_formatarData(a.data)} — ${a.tipoCombustivel}',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '''
Litros.................: ${a.quantidadeLitros}
Valor..................: R\$ ${a.valorPago.toStringAsFixed(2)}
Quilometragem....: ${a.quilometragem} km
Consumo.............: ${a.consumo} km/L
                            ''',
                            style: textTheme.bodyMedium?.copyWith(
                              height: 1.3,
                            ),
                          ),
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: Icon(
                                Icons.edit,
                                color: colors.primary,
                              ),
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
                              icon: Icon(
                                Icons.delete,
                                color: colors.error,
                              ),
                              onPressed: () => _confirmarExclusao(context, a),
                            ),
                          ],
                        ),
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
