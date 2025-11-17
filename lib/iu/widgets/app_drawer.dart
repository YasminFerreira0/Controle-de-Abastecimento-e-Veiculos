import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../screens/veiculos/veiculos_list_screen.dart';
import '../screens/abastecimento/abastecimento_form_screen.dart';
import '../screens/abastecimento/abastecimento_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      child: Column(
        children: [
         
          SizedBox(
            height: 230,  
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: colors.primary,
              ),
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 180,  
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.directions_car, color: colors.primary),
                  title: Text('Meus Veículos', style: textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VeiculosListScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_circle_outline, color: colors.primary),
                  title: Text('Registrar Abastecimento', style: textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AbastecimentoFormScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, color: colors.primary),
                  title: Text('Histórico de Abastecimentos', style: textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AbastecimentosListScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text(
                'Sair',
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                auth.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
