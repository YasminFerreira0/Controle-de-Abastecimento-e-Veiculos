import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:p2_andre/models/Abastecimento.dart';
import 'package:p2_andre/models/Veiculo.dart';

import '../../../services/abastecimento_service.dart';

class AbastecimentoFormScreen extends StatefulWidget {
  final Abastecimento? abastecimento; // null = novo, não null = editar

  const AbastecimentoFormScreen({super.key, this.abastecimento});

  @override
  State<AbastecimentoFormScreen> createState() =>
      _AbastecimentoFormScreenState();
}

class _AbastecimentoFormScreenState extends State<AbastecimentoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime _data = DateTime.now();
  String? _veiculoIdSelecionado;

  final _quantidadeCtrl = TextEditingController();
  final _valorPagoCtrl = TextEditingController();
  final _quilometragemCtrl = TextEditingController();
  final _consumoCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController();

  String _tipoCombustivel = 'Gasolina';
  bool _salvando = false;

  final _service = AbastecimentoService();

  bool get _isEditing => widget.abastecimento != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.abastecimento!;
      _data = a.data;
      _veiculoIdSelecionado = a.veiculoId;
      _quantidadeCtrl.text = a.quantidadeLitros.toString();
      _valorPagoCtrl.text = a.valorPago.toString();
      _quilometragemCtrl.text = a.quilometragem.toString();
      _consumoCtrl.text = a.consumo.toString();
      _tipoCombustivel = a.tipoCombustivel;
      _observacaoCtrl.text = a.observacao ?? '';
    }
  }

  @override
  void dispose() {
    _quantidadeCtrl.dispose();
    _valorPagoCtrl.dispose();
    _quilometragemCtrl.dispose();
    _consumoCtrl.dispose();
    _observacaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final dataEscolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (dataEscolhida != null) {
      setState(() => _data = dataEscolhida);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_veiculoIdSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um veículo')),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final quantidadeLitros =
          double.parse(_quantidadeCtrl.text.replaceAll(',', '.'));
      final valorPago =
          double.parse(_valorPagoCtrl.text.replaceAll(',', '.'));
      final quilometragem = int.parse(_quilometragemCtrl.text.trim());
      final consumo =
          double.parse(_consumoCtrl.text.replaceAll(',', '.'));

      await _service.salvarAbastecimento(
        id: widget.abastecimento?.id,
        data: _data,
        quantidadeLitros: quantidadeLitros,
        valorPago: valorPago,
        quilometragem: quilometragem,
        tipoCombustivel: _tipoCombustivel,
        veiculoId: _veiculoIdSelecionado!,
        consumo: consumo,
        observacao: _observacaoCtrl.text.trim().isEmpty
            ? null
            : _observacaoCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Abastecimento atualizado com sucesso!'
                : 'Abastecimento cadastrado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
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
        title: Text(_isEditing ? 'Editar abastecimento' : 'Novo abastecimento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('veiculos').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Erro ao carregar veículos'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final veiculos = snapshot.data!.docs
                .map(
                  (doc) => Veiculo.fromMap(doc.id, doc.data()),
                )
                .toList();

            if (veiculos.isEmpty) {
              return const Center(
                child: Text(
                    'Nenhum veículo cadastrado. Cadastre um veículo primeiro.'),
              );
            }

            // Se for novo cadastro, define um veículo padrão
            _veiculoIdSelecionado ??= veiculos.first.id;

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  // Data
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data: ${_data.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: _selecionarData,
                        child: const Text('Selecionar data'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Veículo
                  DropdownButtonFormField<String>(
                    value: _veiculoIdSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Veículo',
                      border: OutlineInputBorder(),
                    ),
                    items: veiculos
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text('${v.marca} ${v.modelo} (${v.placa})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _veiculoIdSelecionado = value);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Quantidade de litros
                  TextFormField(
                    controller: _quantidadeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de litros',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a quantidade de litros';
                      }
                      final val = double.tryParse(
                          value.replaceAll(',', '.'));
                      if (val == null || val <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Valor pago
                  TextFormField(
                    controller: _valorPagoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Valor pago (R\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o valor pago';
                      }
                      final val = double.tryParse(
                          value.replaceAll(',', '.'));
                      if (val == null || val <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Quilometragem
                  TextFormField(
                    controller: _quilometragemCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quilometragem (km)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a quilometragem';
                      }
                      final val = int.tryParse(value.trim());
                      if (val == null || val <= 0) {
                        return 'Quilometragem inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Consumo
                  TextFormField(
                    controller: _consumoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Consumo (km/L)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o consumo';
                      }
                      final val = double.tryParse(
                          value.replaceAll(',', '.'));
                      if (val == null || val <= 0) {
                        return 'Consumo inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Tipo de combustível
                  DropdownButtonFormField<String>(
                    value: _tipoCombustivel,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de combustível',
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 10),

                  // Observação
                  TextFormField(
                    controller: _observacaoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Observação (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
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
            );
          },
        ),
      ),
    );
  }
}
