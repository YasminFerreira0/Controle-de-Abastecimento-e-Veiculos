import 'package:flutter/material.dart';
import 'package:p2_andre/iu/screens/veiculos/veiculos_form_screen.dart';
import 'package:p2_andre/models/Veiculo.dart';

import '../../../services/veiculo_service.dart';

class VeiculosListScreen extends StatelessWidget {
  VeiculosListScreen({super.key});

  final _veiculoService = VeiculoService();

  Future<void> _confirmarExclusao(
    BuildContext context,
    Veiculo veiculo,
  ) async {
    final colors = Theme.of(context).colorScheme;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir veículo'),
        content: Text('Tem certeza que deseja excluir "${veiculo.modelo}"?'),
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
        await _veiculoService.deletarVeiculo(veiculo.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo excluído com sucesso')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: colors.onPrimary),
                label: const Text('Novo veículo'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VeiculoFormScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Veiculo>>(
              stream: _veiculoService.streamVeiculos(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar veículos'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final veiculos = snapshot.data!;
                if (veiculos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum veículo cadastrado.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: veiculos.length,
                  itemBuilder: (context, index) {
                    final v = veiculos[index];

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
                          '${v.marca} ${v.modelo}',
                          style: textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '''
Placa..................: ${v.placa}
Ano....................: ${v.ano}
Combustível.......: ${v.tipoCombustivel}
                            ''',
                            style: textTheme.bodyMedium!.copyWith(height: 1.3),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: Icon(Icons.edit, color: colors.primary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VeiculoFormScreen(veiculo: v),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              tooltip: 'Excluir',
                              icon: Icon(Icons.delete, color: colors.error),
                              onPressed: () =>
                                  _confirmarExclusao(context, v),
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
