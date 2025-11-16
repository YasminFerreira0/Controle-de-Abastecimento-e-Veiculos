import 'package:flutter/material.dart';
import 'package:p2_andre/iu/screens/abastecimento/abastecimento_list_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../veiculos/veiculos_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // impede de ocupar tela inteira
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Veículos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VeiculosListScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_gas_station),
              label: const Text('Abastecimentos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AbastecimentosListScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
