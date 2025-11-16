import 'package:flutter/material.dart';
import 'package:p2_andre/models/Veiculo.dart';

import '../../../services/veiculo_service.dart';

class VeiculoFormScreen extends StatefulWidget {
  final Veiculo? veiculo; // null = novo; não null = editar

  const VeiculoFormScreen({super.key, this.veiculo});

  @override
  State<VeiculoFormScreen> createState() => _VeiculoFormScreenState();
}

class _VeiculoFormScreenState extends State<VeiculoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modeloCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _placaCtrl = TextEditingController();
  final _anoCtrl = TextEditingController();
  String _tipoCombustivel = 'Gasolina';

  final _veiculoService = VeiculoService();

  bool _salvando = false;

  bool get _isEditing => widget.veiculo != null;

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos
    if (widget.veiculo != null) {
      final v = widget.veiculo!;
      _modeloCtrl.text = v.modelo;
      _marcaCtrl.text = v.marca;
      _placaCtrl.text = v.placa;
      _anoCtrl.text = v.ano.toString();
      _tipoCombustivel = v.tipoCombustivel;
    }
  }

  @override
  void dispose() {
    _modeloCtrl.dispose();
    _marcaCtrl.dispose();
    _placaCtrl.dispose();
    _anoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final ano = int.tryParse(_anoCtrl.text.trim()) ?? 0;

      await _veiculoService.salvarVeiculo(
        id: widget.veiculo?.id, // null se novo, id se edição
        modelo: _modeloCtrl.text.trim(),
        marca: _marcaCtrl.text.trim(),
        placa: _placaCtrl.text.trim(),
        ano: ano,
        tipoCombustivel: _tipoCombustivel,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Veículo atualizado com sucesso!'
                : 'Veículo cadastrado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context); // volta para a lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar veículo: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final combustiveis = [
      'Gasolina',
      'Etanol',
      'Diesel',
      'GNV',
      'Flex',
      'Elétrico',
      'Híbrido',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar veículo' : 'Novo veículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _modeloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o modelo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _marcaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a marca';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _placaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe a placa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _anoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o ano';
                  }
                  final ano = int.tryParse(value);
                  if (ano == null ||
                      ano < 1900 ||
                      ano > DateTime.now().year + 1) {
                    return 'Ano inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _tipoCombustivel,
                decoration: const InputDecoration(
                  labelText: 'Tipo de combustível',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                ),
                items: combustiveis
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoCombustivel = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  child: _salvando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Atualizar' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
