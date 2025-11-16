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
          TextButton(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
      ),
      body: Column(
        children: [
          // Botão Novo Veículo no topo da tela
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
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
          const Divider(height: 0),
          // Lista de veículos
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final veiculos = snapshot.data!;
                if (veiculos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum veículo cadastrado.'),
                  );
                }

                return ListView.builder(
                  itemCount: veiculos.length,
                  itemBuilder: (context, index) {
                    final v = veiculos[index];
                    return ListTile(
                      title: Text('${v.marca} ${v.modelo}'),
                      subtitle: Text(
                          'Placa: ${v.placa} • Ano: ${v.ano} • ${v.tipoCombustivel}'),
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
                                  builder: (_) =>
                                      VeiculoFormScreen(veiculo: v),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmarExclusao(context, v),
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
